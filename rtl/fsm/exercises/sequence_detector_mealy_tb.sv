// sequence_detector_mealy テストベンチ

module sequence_detector_mealy_tb;
  logic clk;
  logic rst_n;
  logic data_in;
  logic detected;

  // DUT instantiation
  sequence_detector_mealy dut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .detected(detected)
  );

  // Clock generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Helper task to send bit
  task send_bit(input logic bit_val);
    @(negedge clk);  // クロックの中間で入力変更（Mealy型用）
    data_in = bit_val;
  endtask

  // Test stimulus
  initial begin
    $display("=== sequence_detector_mealy Test Start ===");

    // Reset
    rst_n = 0;
    data_in = 0;
    #20;
    rst_n = 1;
    @(posedge clk);

    // Test 1: シーケンス "1011" を検出
    $display("\nTest 1: Detect sequence '1011'");
    send_bit(1);  // 1
    send_bit(0);  // 10
    send_bit(1);  // 101
    send_bit(1);  // 1011 - ここで検出
    #1;  // 組み合わせ回路の安定待ち（posedge前）
    if (detected) $display("PASS: '1011' detected");
    else $display("FAIL: '1011' not detected");
    @(posedge clk);  // 状態更新

    // Test 2: オーバーラップ検出 "10111011"
    $display("\nTest 2: Overlapping detection '1011-1011'");
    data_in = 0;
    @(posedge clk);
    send_bit(1);  // 1
    send_bit(0);  // 10
    send_bit(1);  // 101
    send_bit(1);  // 1011 - 1回目検出
    #1;
    if (detected) $display("  First '1011': PASS");
    else $display("  First '1011': FAIL");
    @(posedge clk);

    send_bit(1);  // 11 (前の最後の"1"を再利用)
    send_bit(0);  // 110 -> 10
    send_bit(1);  // 1101 -> 101
    send_bit(1);  // 11011 -> 1011 - 2回目検出
    #1;
    if (detected) $display("  Second '1011' (overlap): PASS");
    else $display("  Second '1011' (overlap): FAIL");
    @(posedge clk);

    // Test 3: 不一致パターン "1010"
    $display("\nTest 3: Non-matching sequence '1010'");
    data_in = 0;
    repeat(3) @(posedge clk);
    send_bit(1);  // 1
    send_bit(0);  // 10
    send_bit(1);  // 101
    send_bit(0);  // 1010 - 検出されない
    #1;
    if (!detected) $display("PASS: '1010' not detected");
    else $display("FAIL: '1010' incorrectly detected");
    @(posedge clk);

    // Test 4: 連続した1 "1111011"
    $display("\nTest 4: Multiple 1's then '1011'");
    data_in = 0;
    repeat(2) @(posedge clk);
    send_bit(1);  // 1
    send_bit(1);  // 11
    send_bit(1);  // 111
    send_bit(0);  // 1110 -> 10
    send_bit(1);  // 11101 -> 101
    send_bit(1);  // 111011 -> 1011 - 検出
    #1;
    if (detected) $display("PASS: '1011' detected after multiple 1's");
    else $display("FAIL: '1011' not detected");
    @(posedge clk);

    #20;
    $display("\n=== sequence_detector_mealy Test Complete ===");
    $finish;
  end

  // Waveform dump
  initial begin
    $dumpfile("sequence_detector_mealy.vcd");
    $dumpvars(0, sequence_detector_mealy_tb);
  end

endmodule
