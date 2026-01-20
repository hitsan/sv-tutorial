//============================================================================
// File: udp_rx_tb.sv
// Description: UDP RXのテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns / 1ps

module udp_rx_tb;

  localparam int CLK_PERIOD = 10;
  localparam int TIMEOUT_CYCLES = 200;
  localparam int DATA_WIDTH = 8;

  logic                  clk;
  logic                  rst_n;
  logic [DATA_WIDTH-1:0] data_in;
  logic                  valid_in;
  logic [          15:0] src_port;
  logic [          15:0] dst_port;
  logic [DATA_WIDTH-1:0] payload_out;
  logic                  payload_valid;

  int                    error_count = 0;
  int                    test_count = 0;

  // UDPチェックサム計算関数（簡略版：疑似ヘッダなし）
  function automatic logic [15:0] calc_udp_checksum(logic [15:0] src_port_in,
                                                    logic [15:0] dst_port_in, logic [15:0] length,
                                                    logic [7:0] payload[$]);
    logic [31:0] sum;
    int i;

    sum = 0;
    // Source Port
    sum += 32'(src_port_in);
    // Destination Port
    sum += 32'(dst_port_in);
    // Length (counted twice)
    sum += 32'(length);

    // Payload (16bit単位で加算)
    for (i = 0; i < payload.size(); i += 2) begin
      if (i + 1 < payload.size()) begin
        sum += 32'({payload[i], payload[i+1]});
      end else begin
        sum += 32'({payload[i], 8'h00});
      end
    end

    // Carry折り返し
    while ((sum >> 16) != 0) begin
      sum = (sum & 32'hFFFF) + (sum >> 16);
    end

    // 1の補数
    return ~sum[15:0];
  endfunction

  // DUT
  udp_rx #(
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk          (clk),
      .rst_n        (rst_n),
      .data_in      (data_in),
      .valid_in     (valid_in),
      .src_port     (src_port),
      .dst_port     (dst_port),
      .payload_out  (payload_out),
      .payload_valid(payload_valid)
  );

  // クロック生成
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // テストシーケンス
  initial begin
    $dumpfile("udp_rx_tb.vcd");
    $dumpvars(0, udp_rx_tb);

    rst_n = 0;
    data_in = 0;
    valid_in = 0;

    repeat (2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    $display("=== UDP RX Test Start ===");

    // Test 1: 標準的なUDPパケット
    test_count++;
    $display("\n[Test %0d] Standard UDP packet", test_count);
    send_udp_packet(16'd5678,  // Source port
                    16'd1234,  // Destination port
                    '{
                        8'h48,
                        8'h65,
                        8'h6C,
                        8'h6C,
                        8'h6F
                    }  // "Hello"
                        );

    // Test 2: 異なるポート番号
    test_count++;
    $display("\n[Test %0d] Different port numbers", test_count);
    send_udp_packet(16'd9999,  // Source port
                    16'd8080,  // Destination port
                    '{
                        8'h54,
                        8'h65,
                        8'h73,
                        8'h74
                    }  // "Test"
                        );

    // Test 3: 最小ペイロード（1バイト）
    test_count++;
    $display("\n[Test %0d] Minimum payload", test_count);
    send_udp_packet(16'd12345, 16'd1234, '{8'hAA});

    // Test 4: 大きめのペイロード
    test_count++;
    $display("\n[Test %0d] Larger payload", test_count);
    send_udp_packet(16'd54321, 16'd1234,
                    '{
                        8'h00,
                        8'h11,
                        8'h22,
                        8'h33,
                        8'h44,
                        8'h55,
                        8'h66,
                        8'h77,
                        8'h88,
                        8'h99,
                        8'hAA,
                        8'hBB,
                        8'hCC,
                        8'hDD,
                        8'hEE,
                        8'hFF
                    });

    // Test 5: 連続パケット
    test_count++;
    $display("\n[Test %0d] Consecutive packets", test_count);
    send_udp_packet(16'd1111, 16'd1234, '{8'h01, 8'h02});
    send_udp_packet(16'd2222, 16'd1234, '{8'h03, 8'h04});

    // Test 6: 4バイトペイロード
    test_count++;
    $display("\n[Test %0d] 4-byte payload", test_count);
    send_udp_packet_custom_len(16'd3333, 16'd1234, '{8'h10, 8'h11, 8'h12, 8'h13},
                               16'd12  // Header(8) + 4 bytes
        );

    // Test 7: 6バイトペイロード
    test_count++;
    $display("\n[Test %0d] 6-byte payload", test_count);
    send_udp_packet_custom_len(16'd4444, 16'd1234,
                               '{8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25}, 16'd14  // Header(8) + 6 bytes
        );

    repeat (10) @(posedge clk);
    $display("\n=== UDP RX Test Complete ===");
    $display("Total tests: %0d", test_count);
    $display("Errors: %0d", error_count);
    if (error_count == 0) begin
      $display("PASS");
    end else begin
      $display("FAIL");
    end
    $finish;
  end

  task send_udp_packet(input logic [15:0] src_port_exp, input logic [15:0] dst_port_exp,
                       input logic [7:0] payload[$]);
    send_udp_packet_custom_len(src_port_exp, dst_port_exp, payload, 16'd0);
  endtask

  task send_udp_packet_custom_len(input logic [15:0] src_port_exp, input logic [15:0] dst_port_exp,
                                  input logic [7:0] payload[$],
                                  input logic [15:0] udp_length_override);
    int i;
    logic [15:0] src_port_rcv;
    logic [15:0] dst_port_rcv;
    logic [7:0] payload_rcv[$];
    logic [15:0] udp_length;
    logic [15:0] checksum;
    int timeout;
    int expected_payload_len;
    logic extra_payload_seen;

    // UDP length = header(8) + payload
    udp_length = (udp_length_override != 0) ? udp_length_override : 16'(8 + payload.size());
    expected_payload_len = int'(udp_length) - 8;
    extra_payload_seen = 0;
    // チェックサム計算
    checksum = calc_udp_checksum(src_port_exp, dst_port_exp, udp_length, payload);

    // 前のパケットの処理が完了するまで待機
    if (payload_valid) begin
      $display("  [DEBUG] Waiting for previous packet payload_valid to clear...");
      while (payload_valid) @(posedge clk);
      $display("  [DEBUG] payload_valid cleared");
    end

    // 受信バッファを明示的にクリア
    payload_rcv.delete();

    $display("  Sending UDP packet:");
    $display("    SRC port: %0d", src_port_exp);
    $display("    DST port: %0d", dst_port_exp);
    $display("    Length:   %0d bytes", udp_length);
    $display("    Checksum: 0x%04h", checksum);
    $write("    Payload:  ");
    for (int j = 0; j < payload.size(); j++) $write("%02h ", payload[j]);
    $display("");

    // UDPヘッダ送信（big-endian）
    // Source Port (2 bytes)
    @(posedge clk);
    data_in  = src_port_exp[15:8];
    valid_in = 1;
    @(posedge clk);
    data_in  = src_port_exp[7:0];
    valid_in = 1;

    // Destination Port (2 bytes)
    @(posedge clk);
    data_in  = dst_port_exp[15:8];
    valid_in = 1;
    @(posedge clk);
    data_in  = dst_port_exp[7:0];
    valid_in = 1;

    // Length (2 bytes)
    @(posedge clk);
    data_in  = udp_length[15:8];
    valid_in = 1;
    @(posedge clk);
    data_in  = udp_length[7:0];
    valid_in = 1;

    // Checksum (2 bytes)
    @(posedge clk);
    data_in  = checksum[15:8];
    valid_in = 1;
    @(posedge clk);
    data_in  = checksum[7:0];
    valid_in = 1;

    // ペイロード送信と受信監視を並行実行
    fork
      begin
        // ペイロード送信
        for (i = 0; i < payload.size(); i++) begin
          @(posedge clk);
          data_in  = payload[i];
          valid_in = 1;
        end

        // パケット終了
        @(posedge clk);
        valid_in = 0;
      end

      begin
        // ペイロードの受信監視
        timeout  = 0;
        while (timeout < TIMEOUT_CYCLES) begin
          @(posedge clk);
          if (payload_valid) begin
            if (payload_rcv.size() < expected_payload_len) begin
              payload_rcv.push_back(payload_out);
            end else begin
              $display("  [DEBUG] Extra payload detected: 0x%02h", payload_out);
              extra_payload_seen = 1;
            end
          end
          timeout++;
          // Length基準で受信完了
          if (payload_rcv.size() >= expected_payload_len) begin
            break;
          end
        end
      end
    join

    // 結果確認
    src_port_rcv = src_port;
    dst_port_rcv = dst_port;

    $display("  Received:");
    $display("    SRC port: %0d", src_port_rcv);
    $display("    DST port: %0d", dst_port_rcv);
    $write("    Payload:  ");
    for (int j = 0; j < payload_rcv.size(); j++) $write("%02h ", payload_rcv[j]);
    $display("");

    // 検証
    if (src_port_rcv !== src_port_exp) begin
      $display("  [ERROR] Source port mismatch! Expected: %0d, Got: %0d", src_port_exp,
               src_port_rcv);
      error_count++;
    end else if (dst_port_rcv !== dst_port_exp) begin
      $display("  [ERROR] Destination port mismatch! Expected: %0d, Got: %0d", dst_port_exp,
               dst_port_rcv);
      error_count++;
    end else if (timeout >= TIMEOUT_CYCLES && payload_rcv.size() < expected_payload_len) begin
      $display("  [ERROR] Payload shorter than UDP Length field (expected: %0d, got: %0d)",
               expected_payload_len, payload_rcv.size());
      error_count++;
    end else if (extra_payload_seen) begin
      $display("  [ERROR] Payload length exceeded UDP Length field");
      error_count++;
    end else begin
      // ペイロード内容の検証
      logic payload_ok = 1;
      // 受信したペイロードと、送信したペイロードの対応する部分を比較
      for (int j = 0; j < payload_rcv.size(); j++) begin
        if (j < payload.size()) begin
          if (payload_rcv[j] !== payload[j]) begin
            $display("  [ERROR] Payload mismatch at byte %0d: got 0x%02h, expected 0x%02h", j,
                     payload_rcv[j], payload[j]);
            payload_ok = 0;
            error_count++;
            break;
          end
        end else begin
          // 受信が送信より多い（通常はextra_payload_seenで検出されるが念のため）
          $display("  [ERROR] Received more payload than sent at byte %0d: 0x%02h", j,
                   payload_rcv[j]);
          payload_ok = 0;
          error_count++;
          break;
        end
      end
      if (payload_ok) begin
        $display("  [OK] All checks passed");
      end
    end

    // 次のテストのために信号をクリア
    data_in  = 0;
    valid_in = 0;
    repeat (5) @(posedge clk);
  endtask

endmodule
