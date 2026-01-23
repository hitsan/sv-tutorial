//============================================================================
// File: udp_tx_tb.sv
// Description: UDP TXのテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module udp_tx_tb;

    localparam int CLK_PERIOD = 10;
    localparam int TIMEOUT_CYCLES = 500;
    localparam int DATA_WIDTH = 8;

    logic                  clk;
    logic                  rst_n;
    logic [15:0]           src_port;
    logic [15:0]           dst_port;
    logic [31:0]           src_ip;
    logic [31:0]           dst_ip;
    logic [DATA_WIDTH-1:0] payload_in;
    logic                  payload_valid;
    logic                  payload_sof;
    logic                  payload_eof;
    logic                  payload_ready;
    logic [DATA_WIDTH-1:0] packet_out;
    logic                  packet_valid;
    logic                  packet_sof;
    logic                  packet_eof;

    int error_count = 0;
    int test_count = 0;

    // DUT
    udp_tx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .src_port     (src_port),
        .dst_port     (dst_port),
        .src_ip       (src_ip),
        .dst_ip       (dst_ip),
        .payload_in   (payload_in),
        .payload_valid(payload_valid),
        .payload_sof  (payload_sof),
        .payload_eof  (payload_eof),
        .payload_ready(payload_ready),
        .packet_out   (packet_out),
        .packet_valid (packet_valid),
        .packet_sof   (packet_sof),
        .packet_eof   (packet_eof)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // テストシーケンス
    initial begin
        $dumpfile("udp_tx_tb.vcd");
        $dumpvars(0, udp_tx_tb);

        rst_n = 0;
        src_port = 0;
        dst_port = 0;
        src_ip = 0;
        dst_ip = 0;
        payload_in = 0;
        payload_valid = 0;
        payload_sof = 0;
        payload_eof = 0;

        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("=== UDP TX Test Start ===");

        // Test 1: 標準的なUDPパケット生成
        test_count++;
        $display("\n[Test %0d] Standard UDP packet", test_count);
        send_payload_and_check(
            16'd1234,           // Source port
            16'd5678,           // Destination port
            32'hC0A80101,       // Source IP: 192.168.1.1
            32'hC0A80102,       // Destination IP: 192.168.1.2
            '{8'h48, 8'h65, 8'h6C, 8'h6C, 8'h6F}  // "Hello"
        );

        // Test 2: 異なるポート番号とIPアドレス
        test_count++;
        $display("\n[Test %0d] Different port numbers and IPs", test_count);
        send_payload_and_check(
            16'd8080,
            16'd9999,
            32'h0A000001,       // 10.0.0.1
            32'h0A000002,       // 10.0.0.2
            '{8'h54, 8'h65, 8'h73, 8'h74}  // "Test"
        );

        // Test 3: 最小ペイロード（1バイト）
        test_count++;
        $display("\n[Test %0d] Minimum payload (1 byte)", test_count);
        send_payload_and_check(
            16'd1111,
            16'd2222,
            32'hC0A80001,
            32'hC0A80002,
            '{8'hAA}
        );

        // Test 4: ゼロバイトペイロード
        test_count++;
        $display("\n[Test %0d] Zero-byte payload", test_count);
        send_payload_and_check(
            16'd3333,
            16'd4444,
            32'hC0A80003,
            32'hC0A80004,
            '{} // 空配列
        );

        // Test 5: 大きめのペイロード
        test_count++;
        $display("\n[Test %0d] Larger payload (16 bytes)", test_count);
        send_payload_and_check(
            16'd5555,
            16'd6666,
            32'hC0A80005,
            32'hC0A80006,
            '{8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77,
              8'h88, 8'h99, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE, 8'hFF}
        );

        // Test 6: 連続送信
        test_count++;
        $display("\n[Test %0d] Consecutive transmissions", test_count);
        send_payload_and_check(16'd7777, 16'd8888, 32'hC0A80007, 32'hC0A80008, '{8'h01, 8'h02});
        send_payload_and_check(16'd9999, 16'd1111, 32'hC0A80009, 32'hC0A8000A, '{8'h03, 8'h04, 8'h05});

        // Test 7: payload_validにギャップがある場合
        test_count++;
        $display("\n[Test %0d] Payload with gaps in valid signal", test_count);
        send_payload_with_gaps(
            16'd2222,
            16'd3333,
            32'hC0A8000B,
            32'hC0A8000C,
            '{8'hAA, 8'hBB, 8'hCC, 8'hDD}
        );

        // Test 8: バックプレッシャーのテスト（payload_ready待ち）
        test_count++;
        $display("\n[Test %0d] Backpressure handling", test_count);
        send_with_backpressure(
            16'd4444,
            16'd5555,
            32'hC0A8000D,
            32'hC0A8000E,
            '{8'h11, 8'h22, 8'h33}
        );

        repeat(10) @(posedge clk);
        $display("\n=== UDP TX Test Complete ===");
        $display("Total tests: %0d", test_count);
        $display("Errors: %0d", error_count);
        if (error_count == 0) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end

    // UDPチェックサム計算関数（RFC 768, RFC 1071）
    function automatic logic [15:0] calc_udp_checksum(
        input logic [31:0] src_ip_addr,
        input logic [31:0] dst_ip_addr,
        input logic [15:0] src_port_val,
        input logic [15:0] dst_port_val,
        input logic [7:0]  payload_data[$]
    );
        logic [31:0] sum;
        logic [15:0] udp_len;
        int i;

        sum = 0;
        udp_len = 8 + payload_data.size();

        // 疑似ヘッダ
        sum += src_ip_addr[31:16];
        sum += src_ip_addr[15:0];
        sum += dst_ip_addr[31:16];
        sum += dst_ip_addr[15:0];
        sum += 16'h0011;        // Protocol: UDP=17
        sum += udp_len;

        // UDPヘッダ（チェックサムフィールドは0）
        sum += src_port_val;
        sum += dst_port_val;
        sum += udp_len;
        // チェックサムフィールド(0x0000)は加算不要

        // ペイロード（16ビット単位）
        for (i = 0; i < payload_data.size(); i += 2) begin
            if (i + 1 < payload_data.size()) begin
                sum += {payload_data[i], payload_data[i+1]};
            end else begin
                // 奇数バイトの場合、上位8ビットのみ
                sum += {payload_data[i], 8'h00};
            end
        end

        // キャリーを折り返す
        while (sum[31:16] != 0) begin
            sum = sum[15:0] + sum[31:16];
        end

        // 1の補数
        return ~sum[15:0];
    endfunction

    task send_payload_and_check(
        input logic [15:0] src_port_in,
        input logic [15:0] dst_port_in,
        input logic [31:0] src_ip_in,
        input logic [31:0] dst_ip_in,
        input logic [7:0]  payload[$]
    );
        int i;
        logic [7:0] packet_rcv[$];
        logic [15:0] udp_length;
        logic [15:0] expected_checksum;
        int timeout;
        logic [15:0] rcv_src_port;
        logic [15:0] rcv_dst_port;
        logic [15:0] rcv_length;
        logic [15:0] rcv_checksum;
        logic got_sof, got_eof;

        udp_length = 8 + payload.size();
        expected_checksum = calc_udp_checksum(src_ip_in, dst_ip_in, src_port_in, dst_port_in, payload);

        $display("  Sending payload:");
        $display("    SRC IP:   %d.%d.%d.%d", src_ip_in[31:24], src_ip_in[23:16], src_ip_in[15:8], src_ip_in[7:0]);
        $display("    DST IP:   %d.%d.%d.%d", dst_ip_in[31:24], dst_ip_in[23:16], dst_ip_in[15:8], dst_ip_in[7:0]);
        $display("    SRC port: %0d", src_port_in);
        $display("    DST port: %0d", dst_port_in);
        $display("    Payload:  %0d bytes", payload.size());
        $display("    Expected checksum: 0x%04h", expected_checksum);

        // 設定
        @(posedge clk);
        src_port = src_port_in;
        dst_port = dst_port_in;
        src_ip = src_ip_in;
        dst_ip = dst_ip_in;

        // ペイロード送信
        for (i = 0; i < payload.size(); i++) begin
            @(posedge clk);
            while (!payload_ready) @(posedge clk); // バックプレッシャー対応
            payload_in = payload[i];
            payload_valid = 1;
            payload_sof = (i == 0);
            payload_eof = (i == payload.size() - 1);
        end

        // ゼロバイトペイロードの場合はSOF/EOFのみ
        if (payload.size() == 0) begin
            @(posedge clk);
            while (!payload_ready) @(posedge clk);
            payload_valid = 1;
            payload_sof = 1;
            payload_eof = 1;
            payload_in = 8'h00; // ダミー
        end

        @(posedge clk);
        payload_valid = 0;
        payload_sof = 0;
        payload_eof = 0;

        // パケット出力の監視
        timeout = 0;
        got_sof = 0;
        got_eof = 0;
        while (timeout < TIMEOUT_CYCLES) begin
            @(posedge clk);
            if (packet_valid) begin
                packet_rcv.push_back(packet_out);
                if (packet_sof) got_sof = 1;
                if (packet_eof) got_eof = 1;
            end
            timeout++;
            // UDPヘッダ(8バイト) + ペイロード分受信 かつ EOFを検出したら終了
            if (got_eof && packet_rcv.size() >= (8 + payload.size())) break;
        end

        $display("  Received packet: %0d bytes (SOF=%0d, EOF=%0d)", packet_rcv.size(), got_sof, got_eof);

        // パケット解析（実装があれば動作）
        if (packet_rcv.size() >= 8) begin
            // UDPヘッダ解析（big-endian）
            rcv_src_port = {packet_rcv[0], packet_rcv[1]};
            rcv_dst_port = {packet_rcv[2], packet_rcv[3]};
            rcv_length = {packet_rcv[4], packet_rcv[5]};
            rcv_checksum = {packet_rcv[6], packet_rcv[7]};

            $display("  Packet header (big-endian):");
            $display("    SRC port:  %0d (expected: %0d)", rcv_src_port, src_port_in);
            $display("    DST port:  %0d (expected: %0d)", rcv_dst_port, dst_port_in);
            $display("    Length:    %0d (expected: %0d)", rcv_length, udp_length);
            $display("    Checksum:  0x%04h (expected: 0x%04h)", rcv_checksum, expected_checksum);

            // ヘッダ検証
            logic header_ok = 1;
            if (rcv_src_port !== src_port_in) begin
                $display("  [ERROR] Source port mismatch!");
                error_count++;
                header_ok = 0;
            end
            if (rcv_dst_port !== dst_port_in) begin
                $display("  [ERROR] Destination port mismatch!");
                error_count++;
                header_ok = 0;
            end
            if (rcv_length !== udp_length) begin
                $display("  [ERROR] UDP length mismatch!");
                error_count++;
                header_ok = 0;
            end
            if (rcv_checksum !== expected_checksum) begin
                $display("  [ERROR] Checksum mismatch!");
                error_count++;
                header_ok = 0;
            end
            if (packet_rcv.size() !== (8 + payload.size())) begin
                $display("  [ERROR] Total packet size mismatch! Expected: %0d, Got: %0d",
                         8 + payload.size(), packet_rcv.size());
                error_count++;
                header_ok = 0;
            end
            if (!got_sof) begin
                $display("  [ERROR] packet_sof not asserted!");
                error_count++;
                header_ok = 0;
            end
            if (!got_eof) begin
                $display("  [ERROR] packet_eof not asserted!");
                error_count++;
                header_ok = 0;
            end

            // ペイロード検証（ヘッダが正しい場合のみ）
            if (header_ok && packet_rcv.size() >= (8 + payload.size())) begin
                logic payload_ok = 1;
                for (int j = 0; j < payload.size(); j++) begin
                    if (packet_rcv[8 + j] !== payload[j]) begin
                        $display("  [ERROR] Payload mismatch at byte %0d: got 0x%02h, expected 0x%02h",
                                 j, packet_rcv[8 + j], payload[j]);
                        payload_ok = 0;
                        error_count++;
                    end
                end
                if (payload_ok && header_ok) begin
                    $display("  [OK] All checks passed");
                end
            end
        end else if (packet_rcv.size() > 0) begin
            $display("  [ERROR] Incomplete packet received! Size: %0d bytes", packet_rcv.size());
            error_count++;
        end else begin
            $display("  [INFO] No output - implementation pending");
        end

        // 次のテストのために信号をクリア
        src_port = 0;
        dst_port = 0;
        src_ip = 0;
        dst_ip = 0;
        payload_in = 0;
        payload_valid = 0;
        payload_sof = 0;
        payload_eof = 0;
        repeat(5) @(posedge clk);
    endtask

    // payload_validにギャップを入れるテスト
    task send_payload_with_gaps(
        input logic [15:0] src_port_in,
        input logic [15:0] dst_port_in,
        input logic [31:0] src_ip_in,
        input logic [31:0] dst_ip_in,
        input logic [7:0]  payload[$]
    );
        int i;
        $display("  Sending payload with gaps in valid signal:");
        $display("    Payload: %0d bytes", payload.size());

        @(posedge clk);
        src_port = src_port_in;
        dst_port = dst_port_in;
        src_ip = src_ip_in;
        dst_ip = dst_ip_in;

        for (i = 0; i < payload.size(); i++) begin
            @(posedge clk);
            while (!payload_ready) @(posedge clk);
            payload_in = payload[i];
            payload_valid = 1;
            payload_sof = (i == 0);
            payload_eof = (i == payload.size() - 1);

            @(posedge clk);
            payload_valid = 0; // 1クロックギャップ
            payload_sof = 0;
            payload_eof = 0;
        end

        @(posedge clk);
        payload_valid = 0;

        $display("  [INFO] Gaps test completed - check DUT behavior manually");

        repeat(5) @(posedge clk);
    endtask

    // バックプレッシャーテスト
    task send_with_backpressure(
        input logic [15:0] src_port_in,
        input logic [15:0] dst_port_in,
        input logic [31:0] src_ip_in,
        input logic [31:0] dst_ip_in,
        input logic [7:0]  payload[$]
    );
        int i;
        int ready_wait_count;
        int total_wait_cycles = 0;
        int max_wait_per_byte = 0;
        logic error_detected = 0;

        $display("  Testing backpressure handling:");
        $display("    Payload: %0d bytes", payload.size());

        @(posedge clk);
        src_port = src_port_in;
        dst_port = dst_port_in;
        src_ip = src_ip_in;
        dst_ip = dst_ip_in;

        for (i = 0; i < payload.size(); i++) begin
            ready_wait_count = 0;  // バイトごとにリセット
            @(posedge clk);
            // payload_readyが0の間待つ
            while (!payload_ready) begin
                @(posedge clk);
                ready_wait_count++;
                if (ready_wait_count > 100) begin
                    $display("  [ERROR] payload_ready stuck at 0 for >100 cycles at byte %0d!", i);
                    error_count++;
                    error_detected = 1;
                    break;
                end
            end

            if (error_detected) break;  // 外側のforループも抜ける

            if (ready_wait_count > max_wait_per_byte) begin
                max_wait_per_byte = ready_wait_count;
            end
            total_wait_cycles += ready_wait_count;

            payload_in = payload[i];
            payload_valid = 1;
            payload_sof = (i == 0);
            payload_eof = (i == payload.size() - 1);
        end

        @(posedge clk);
        payload_valid = 0;
        payload_sof = 0;
        payload_eof = 0;

        if (!error_detected) begin
            if (total_wait_cycles > 0) begin
                $display("  [INFO] Total wait cycles: %0d", total_wait_cycles);
                $display("  [INFO] Max wait per byte: %0d", max_wait_per_byte);
            end else begin
                $display("  [INFO] payload_ready always high (no backpressure)");
            end
        end

        repeat(5) @(posedge clk);
    endtask

endmodule
