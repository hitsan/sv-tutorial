//============================================================================
// File: eth_rx_parser_tb.sv
// Description: Ethernet RX Parserのテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns / 1ps

module eth_rx_parser_tb;

  localparam int CLK_PERIOD = 10;
  localparam int TIMEOUT_CYCLES = 200;
  localparam int DATA_WIDTH = 8;
  localparam int GAP_CYCLES_ERROR = 1;

  logic                  clk;
  logic                  rst_n;
  logic [DATA_WIDTH-1:0] data_in;
  logic                  valid_in;
  logic [          47:0] dst_mac;
  logic [          47:0] src_mac;
  logic [          15:0] ether_type;
  logic [DATA_WIDTH-1:0] payload_out;
  logic                  payload_valid;
  logic                  frame_err;
  logic [           7:0] payload_rcv_q   [$];

  int                    error_count = 0;
  int                    test_count = 0;

  // DUT
  eth_rx_parser #(
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk          (clk),
      .rst_n        (rst_n),
      .data_in      (data_in),
      .valid_in     (valid_in),
      .dst_mac      (dst_mac),
      .src_mac      (src_mac),
      .ether_type   (ether_type),
      .payload_out  (payload_out),
      .payload_valid(payload_valid),
      .frame_err    (frame_err)
  );

  // クロック生成
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // テストシーケンス
  initial begin
    $dumpfile("eth_rx_parser_tb.vcd");
    $dumpvars(0, eth_rx_parser_tb);

    rst_n = 0;
    data_in = 0;
    valid_in = 0;

    repeat (2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    $display("=== Ethernet RX Parser Test Start ===");

    // Test 1: 標準的なEthernetフレーム (IPv4)
    test_count++;
    $display("\n[Test %0d] Standard IPv4 frame", test_count);
    send_ethernet_frame("Standard IPv4 frame",
                        48'hFFFF_FFFF_FFFF,  // Destination MAC (broadcast)
                        48'h0011_2233_4455,  // Source MAC
                        16'h0806,  // EtherType (IPv4)
                        '{
                            8'h45,
                            8'h00,
                            8'h00,
                            8'h14
                        }  // Payload (IP header start)
                            );

    // Test 2: ARP frame
    test_count++;
    $display("\n[Test %0d] ARP frame", test_count);
    send_ethernet_frame("ARP frame",
                        48'hFFFF_FFFF_FFFF,  // Destination MAC
                        48'h0011_2233_4455,  // Source MAC
                        16'h0800,  // EtherType (ARP)
                        '{
                            8'h00,
                            8'h01,
                            8'h08,
                            8'h00
                        }  // Payload (ARP data)
                            );

    // Test 3: IPv6 frame
    test_count++;
    $display("\n[Test %0d] IPv6 frame", test_count);
    send_ethernet_frame("IPv6 frame",
                        48'h3333_0000_0001,  // Destination MAC (IPv6 multicast)
                        48'h0011_2233_4455,  // Source MAC
                        16'h86DD,  // EtherType (IPv6)
                        '{
                            8'h60,
                            8'h00,
                            8'h00,
                            8'h00
                        }  // Payload (IPv6 header start)
                            );

    // Test 4: Unicast frame with specific MAC
    test_count++;
    $display("\n[Test %0d] Unicast frame", test_count);
    send_ethernet_frame("Unicast frame",
                        48'hAA_BB_CC_DD_EE_FF,  // Destination MAC
                        48'h11_22_33_44_55_66,  // Source MAC
                        16'h0800,  // EtherType (IPv4)
                        '{
                            8'hDE,
                            8'hAD,
                            8'hBE,
                            8'hEF
                        }  // Payload
                            );

    // Test 5: Short payload
    test_count++;
    $display("\n[Test %0d] Short payload", test_count);
    send_ethernet_frame("Short payload",
                        48'hFFFF_FFFF_FFFF, 48'h0011_2233_4455, 16'h0800,
                        '{
                            8'hAA
                        }  // Single byte payload
                            );

    // Test 6: Payload gap (should error)
    test_count++;
    $display("\n[Test %0d] Payload gap (should error)", test_count);
    send_ethernet_frame("Payload gap (should error)",
                        48'hFFFF_FFFF_FFFF, 48'h0011_2233_4455, 16'h0800,
                        '{8'h01, 8'h02, 8'h03, 8'h04},
                        GAP_CYCLES_ERROR, 1
                            );

    // Test 7: Header gap (should error)
    test_count++;
    $display("\n[Test %0d] Header gap (should error)", test_count);
    send_ethernet_frame("Header gap (should error)",
                        48'hFFFF_FFFF_FFFF, 48'h0011_2233_4455, 16'h0800,
                        '{8'h10, 8'h20, 8'h30, 8'h40}, GAP_CYCLES_ERROR, 1);

    // Test 8: Multi-cycle gap (should error)
    test_count++;
    $display("\n[Test %0d] Multi-cycle gap (should error)", test_count);
    send_ethernet_frame("Multi-cycle gap (should error)",
                        48'hFFFF_FFFF_FFFF, 48'h0011_2233_4455, 16'h0800, '{8'hAA, 8'hBB},
                        GAP_CYCLES_ERROR + 2, 1);

    // Test 9: Bad preamble byte (should error)
    test_count++;
    $display("\n[Test %0d] Bad preamble byte (should error)", test_count);
    send_bad_preamble_byte("Bad preamble byte (should error)", 3);

    // Test 10: Bad SFD (should error)
    test_count++;
    $display("\n[Test %0d] Bad SFD (should error)", test_count);
    send_bad_sfd("Bad SFD (should error)", 8'hD4);

    // Test 11: Short header (should error)
    test_count++;
    $display("\n[Test %0d] Short header (should error)", test_count);
    send_short_header("Short header (should error)", 3);

    repeat (10) @(posedge clk);
    $display("\n=== Ethernet RX Parser Test Complete ===");
    $display("Total tests: %0d", test_count);
    $display("Errors: %0d", error_count);
    if (error_count == 0) begin
      $display("PASS");
    end else begin
      $display("FAIL");
    end
    $finish;
  end

  // ペイロード監視（フレーム送信中も取り逃し防止）
  always @(posedge clk) begin
    if (payload_valid) begin
      payload_rcv_q.push_back(payload_out);
    end
  end

  task send_ethernet_frame(input string test_name, input logic [47:0] dst_mac_exp,
                           input logic [47:0] src_mac_exp,
                           input logic [15:0] etype_exp, input logic [7:0] payload[$],
                           input int gap_cycles = 0, input logic expect_error = 0);
    int i;
    logic [47:0] dst_mac_rcv;
    logic [47:0] src_mac_rcv;
    logic [15:0] etype_rcv;
    logic frame_err_detected;
    int timeout;
    int error_before;

    error_before = error_count;

    $display("  Sending frame: %s", test_name);
    $display("    DST MAC:    %012h", dst_mac_exp);
    $display("    SRC MAC:    %012h", src_mac_exp);
    $display("    EtherType:  0x%04h", etype_exp);
    $display("    Payload:    %0d bytes", payload.size());

    payload_rcv_q.delete();

    frame_err_detected = 0;

    // プリアンブル送信 (7バイト 0x55)
    for (i = 0; i < 7; i++) begin
      send_byte_with_gap(8'h55, 0, frame_err_detected);
    end

    // SFD送信 (0xD5)
    send_byte_with_gap(8'hD5, 0, frame_err_detected);

    // 宛先MACアドレス送信 (6バイト、MSB first)
    for (i = 0; i < 6; i++) begin
      send_byte_with_gap(dst_mac_exp[47-i*8-:8], gap_cycles, frame_err_detected);
    end

    // 送信元MACアドレス送信 (6バイト、MSB first)
    for (i = 0; i < 6; i++) begin
      send_byte_with_gap(src_mac_exp[47-i*8-:8], gap_cycles, frame_err_detected);
    end

    // EtherType送信 (2バイト、MSB first)
    send_byte_with_gap(etype_exp[15:8], gap_cycles, frame_err_detected);
    send_byte_with_gap(etype_exp[7:0], gap_cycles, frame_err_detected);

    // ペイロード送信
    for (i = 0; i < payload.size(); i++) begin
      send_byte_with_gap(payload[i], gap_cycles, frame_err_detected);
    end

    // フレーム終了
    @(negedge clk);
    valid_in = 0;

    // ペイロードの受信監視（ヘッダパースと並行）
    timeout  = 0;
    while (timeout < TIMEOUT_CYCLES) begin
      @(posedge clk);
      if (frame_err) frame_err_detected = 1;
      timeout++;
      // ペイロード受信完了判定: 期待サイズ分受信 & 3サイクル連続でvalidが0
      if (payload_rcv_q.size() >= payload.size()) begin
        int no_valid_count = 0;
        for (int k = 0; k < 3; k++) begin
          @(posedge clk);
          if (frame_err) frame_err_detected = 1;
          if (!payload_valid) no_valid_count++;
        end
        if (no_valid_count >= 2) break;
      end
    end
    if (timeout >= TIMEOUT_CYCLES) begin
      if (!expect_error) begin
        $display("  [ERROR] Payload receive timeout!");
        error_count++;
      end
    end

    // 結果確認（実装があれば動作）
    dst_mac_rcv = dst_mac;
    src_mac_rcv = src_mac;
    etype_rcv   = ether_type;

    $display("  Received:");
    $display("    DST MAC:    %012h", dst_mac_rcv);
    $display("    SRC MAC:    %012h", src_mac_rcv);
    $display("    EtherType:  0x%04h", etype_rcv);
    $display("    Payload:    %0d bytes received", payload_rcv_q.size());

    if (frame_err) frame_err_detected = 1;

    if (expect_error) begin
      // エラーが期待される場合
      if (frame_err_detected) begin
        $display("  [OK] Frame error detected as expected");
      end else begin
        $display("  [ERROR] Expected frame error but frame was valid! (%s)", test_name);
        error_count++;
      end
    end else begin
      // 正常なフレームが期待される場合
      if (frame_err_detected) begin
        $display("  [ERROR] Unexpected frame error! (%s)", test_name);
        error_count++;
      end else begin
        // 通常の検証
        if (dst_mac_rcv !== dst_mac_exp) begin
          $display("  [ERROR] DST MAC mismatch! (%s)", test_name);
          error_count++;
        end else if (src_mac_rcv !== src_mac_exp) begin
          $display("  [ERROR] SRC MAC mismatch! (%s)", test_name);
          error_count++;
        end else if (etype_rcv !== etype_exp) begin
          $display("  [ERROR] EtherType mismatch! (%s)", test_name);
          error_count++;
        end else if (payload.size() > 0 && payload_rcv_q.size() == 0) begin
          $display("  [ERROR] Payload missing! Expected: %0d bytes (%s)", payload.size(),
                   test_name);
          error_count++;
        end else if (payload_rcv_q.size() > 0 && payload_rcv_q.size() !== payload.size()) begin
          $display("  [ERROR] Payload size mismatch! Expected: %0d, Got: %0d", payload.size(),
                   payload_rcv_q.size());
          error_count++;
        end else if (payload_rcv_q.size() > 0) begin
          // ペイロード内容の検証
          logic payload_ok = 1;
          for (int m = 0; m < payload.size(); m++) begin
            if (payload_rcv_q[m] !== payload[m]) begin
              $display("  [ERROR] Payload mismatch at byte %0d: got 0x%02h, expected 0x%02h", m,
                       payload_rcv_q[m], payload[m]);
              payload_ok = 0;
              error_count++;
              break;
            end
          end
          if (payload_ok) begin
            $display("  [OK]");
          end
        end else begin
          $display("  [OK]");
        end
      end
    end

    // 次のテストのために信号をクリア
    data_in  = 0;
    valid_in = 0;
    repeat (5) @(posedge clk);
  endtask

  task send_bad_preamble_byte(input string test_name, input int bad_pos);
    int i;
    logic frame_err_detected;

    payload_rcv_q.delete();
    frame_err_detected = 0;

    for (i = 0; i < 7; i++) begin
      if (i == bad_pos) send_byte_with_gap(8'h54, 0, frame_err_detected);
      else send_byte_with_gap(8'h55, 0, frame_err_detected);
    end
    send_byte_with_gap(8'hD5, 0, frame_err_detected);

    @(negedge clk);
    valid_in = 0;

    repeat (5) begin
      @(posedge clk);
      if (frame_err) frame_err_detected = 1;
    end

    if (frame_err_detected) $display("  [OK] Frame error detected as expected (%s)", test_name);
    else begin
      $display("  [ERROR] Expected frame error but frame was valid! (%s)", test_name);
      error_count++;
    end

    data_in  = 0;
    valid_in = 0;
    repeat (5) @(posedge clk);
  endtask

  task send_bad_sfd(input string test_name, input logic [7:0] bad_sfd);
    int i;
    logic frame_err_detected;

    payload_rcv_q.delete();
    frame_err_detected = 0;

    for (i = 0; i < 7; i++) begin
      send_byte_with_gap(8'h55, 0, frame_err_detected);
    end
    send_byte_with_gap(bad_sfd, 0, frame_err_detected);

    @(negedge clk);
    valid_in = 0;

    repeat (5) begin
      @(posedge clk);
      if (frame_err) frame_err_detected = 1;
    end

    if (frame_err_detected) $display("  [OK] Frame error detected as expected (%s)", test_name);
    else begin
      $display("  [ERROR] Expected frame error but frame was valid! (%s)", test_name);
      error_count++;
    end

    data_in  = 0;
    valid_in = 0;
    repeat (5) @(posedge clk);
  endtask

  task send_short_header(input string test_name, input int da_bytes);
    int i;
    logic frame_err_detected;

    payload_rcv_q.delete();
    frame_err_detected = 0;

    for (i = 0; i < 7; i++) begin
      send_byte_with_gap(8'h55, 0, frame_err_detected);
    end
    send_byte_with_gap(8'hD5, 0, frame_err_detected);

    for (i = 0; i < da_bytes; i++) begin
      send_byte_with_gap(8'hAA, 0, frame_err_detected);
    end

    @(negedge clk);
    valid_in = 0;

    repeat (5) begin
      @(posedge clk);
      if (frame_err) frame_err_detected = 1;
    end

    if (frame_err_detected) $display("  [OK] Frame error detected as expected (%s)", test_name);
    else begin
      $display("  [ERROR] Expected frame error but frame was valid! (%s)", test_name);
      error_count++;
    end

    data_in  = 0;
    valid_in = 0;
    repeat (5) @(posedge clk);
  endtask

  task send_byte_with_gap(input logic [7:0] data_byte, input int gap_cycles,
                          ref logic frame_err_detected);
    @(negedge clk);
    data_in  = data_byte;
    valid_in = 1;
    @(posedge clk);
    if (frame_err) frame_err_detected = 1;
    if (gap_cycles > 0) begin
      repeat (gap_cycles) begin
        @(negedge clk);
        data_in  = 0;
        valid_in = 0;
        @(posedge clk);
        if (frame_err) frame_err_detected = 1;
      end
    end
  endtask

endmodule
