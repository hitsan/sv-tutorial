// edge_detector_moore テストベンチ

module edge_detector_moore_tb;
  logic clk;
  logic rst_n;
  logic data_in;
  logic edge_detected;

  // DUT instantiation
  edge_detector_moore dut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .edge_detected(edge_detected)
  );

  // Clock generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    $display("=== edge_detector_moore Test Start ===");

    // Reset
    rst_n = 0;
    data_in = 0;
    #20;
    rst_n = 1;
    #10;

    // Test 1: 0→1 エッジ検出（Moore型は1サイクル遅延）
    $display("\nTest 1: Detect 0->1 edge (Moore: 1 cycle delay)");
    data_in = 0;
    #10;
    data_in = 1;
    #10;  // 次のクロックエッジ
    #1;   // クロック後の安定待ち
    if (edge_detected) $display("PASS: Edge detected (1 cycle after input)");
    else $display("FAIL: Edge not detected");

    // Test 2: DETECTED状態後はedge_detected=0
    $display("\nTest 2: Edge signal is pulse (1 cycle)");
    #10;
    if (!edge_detected) $display("PASS: Edge is a pulse");
    else $display("FAIL: Edge continues");

    // Test 3: 1→0 遷移ではedge_detected=0
    $display("\nTest 3: No edge on 1->0 transition");
    data_in = 0;
    #10;
    #1;
    if (!edge_detected) $display("PASS: No edge on falling");
    else $display("FAIL: Edge on falling edge");

    // Test 4: もう一度0→1エッジ
    $display("\nTest 4: Detect second 0->1 edge");
    data_in = 1;
    #10;
    #1;
    if (edge_detected) $display("PASS: Second edge detected");
    else $display("FAIL: Second edge not detected");

    #20;
    $display("\n=== edge_detector_moore Test Complete ===");
    $finish;
  end

  // Waveform dump
  initial begin
    $dumpfile("edge_detector_moore.vcd");
    $dumpvars(0, edge_detector_moore_tb);
  end

endmodule
