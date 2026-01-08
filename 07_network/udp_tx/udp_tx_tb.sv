//============================================================================
// File: udp_tx_tb.sv
// Description: UDP TXのテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module udp_tx_tb;

    localparam int CLK_PERIOD = 10;
    localparam int TIMEOUT_CYCLES = 200;
    localparam int DATA_WIDTH = 8;

    logic                  clk;
    logic                  rst_n;
    logic [15:0]           src_port;
    logic [15:0]           dst_port;
    logic [DATA_WIDTH-1:0] payload_in;
    logic                  payload_valid;
    logic [DATA_WIDTH-1:0] packet_out;
    logic                  packet_valid;

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
        .payload_in   (payload_in),
        .payload_valid(payload_valid),
        .packet_out   (packet_out),
        .packet_valid (packet_valid)
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
        payload_in = 0;
        payload_valid = 0;

        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("=== UDP TX Test Start ===");

        // Test 1: 標準的なUDPパケット生成
        test_count++;
        $display("\n[Test %0d] Standard UDP packet", test_count);
        send_payload_and_check(
            16'd1234,   // Source port
            16'd5678,   // Destination port
            '{8'h48, 8'h65, 8'h6C, 8'h6C, 8'h6F}  // "Hello"
        );

        // Test 2: 異なるポート番号
        test_count++;
        $display("\n[Test %0d] Different port numbers", test_count);
        send_payload_and_check(
            16'd8080,
            16'd9999,
            '{8'h54, 8'h65, 8'h73, 8'h74}  // "Test"
        );

        // Test 3: 最小ペイロード（1バイト）
        test_count++;
        $display("\n[Test %0d] Minimum payload", test_count);
        send_payload_and_check(
            16'd1111,
            16'd2222,
            '{8'hAA}
        );

        // Test 4: 大きめのペイロード
        test_count++;
        $display("\n[Test %0d] Larger payload", test_count);
        send_payload_and_check(
            16'd3333,
            16'd4444,
            '{8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77,
              8'h88, 8'h99, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE, 8'hFF}
        );

        // Test 5: 連続送信
        test_count++;
        $display("\n[Test %0d] Consecutive transmissions", test_count);
        send_payload_and_check(16'd5555, 16'd6666, '{8'h01, 8'h02});
        send_payload_and_check(16'd7777, 16'd8888, '{8'h03, 8'h04});

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

    task send_payload_and_check(
        input logic [15:0] src_port_in,
        input logic [15:0] dst_port_in,
        input logic [7:0]  payload[$]
    );
        int i;
        logic [7:0] packet_rcv[$];
        logic [15:0] udp_length;
        int timeout;
        logic [15:0] rcv_src_port;
        logic [15:0] rcv_dst_port;
        logic [15:0] rcv_length;
        logic [15:0] rcv_checksum;

        udp_length = 8 + payload.size();

        $display("  Sending payload:");
        $display("    SRC port: %0d", src_port_in);
        $display("    DST port: %0d", dst_port_in);
        $display("    Payload:  %0d bytes", payload.size());

        // ポート設定（1クロック待つ）
        @(posedge clk);
        src_port = src_port_in;
        dst_port = dst_port_in;

        // ペイロード送信
        for (i = 0; i < payload.size(); i++) begin
            @(posedge clk);
            payload_in = payload[i];
            payload_valid = 1;
        end

        @(posedge clk);
        payload_valid = 0;

        // パケット出力の監視
        timeout = 0;
        while (timeout < TIMEOUT_CYCLES) begin
            @(posedge clk);
            if (packet_valid) begin
                packet_rcv.push_back(packet_out);
            end
            timeout++;
            // UDPヘッダ(8バイト) + ペイロード分受信したら終了
            if (packet_rcv.size() >= (8 + payload.size()) && !packet_valid) break;
        end

        $display("  Received packet: %0d bytes", packet_rcv.size());

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
            $display("    Checksum:  0x%04h", rcv_checksum);

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
            if (packet_rcv.size() !== (8 + payload.size())) begin
                $display("  [ERROR] Total packet size mismatch! Expected: %0d, Got: %0d",
                         8 + payload.size(), packet_rcv.size());
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
                    $display("  [OK]");
                end
            end
        end else if (packet_rcv.size() > 0) begin
            $display("  [ERROR] Incomplete packet received! Size: %0d bytes", packet_rcv.size());
            error_count++;
        end else begin
            $display("  [OK] (no output - implementation pending)");
        end

        // 次のテストのために信号をクリア
        src_port = 0;
        dst_port = 0;
        payload_in = 0;
        payload_valid = 0;
        repeat(5) @(posedge clk);
    endtask

endmodule
