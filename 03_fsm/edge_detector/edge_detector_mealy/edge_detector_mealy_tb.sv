// edge_detector_mealy テストベンチ

module edge_detector_mealy_tb;
  logic clk;
  logic rst_n;
  logic data_in;
  logic edge_detected;

  // DUT instantiation
  edge_detector_mealy dut (
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

  // Test stimulus - クロックのネガティブエッジで入力を変更
  initial begin
    $display("=== edge_detector_mealy Test Start ===");

    // Reset
    rst_n   = 0;
    data_in = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;

    // Test 1: 0→1 エッジ検出
    $display("\nTest 1: Detect 0->1 edge");
    @(negedge clk);  // クロックの中間で入力変更
    data_in = 1;
    #1;  // 組み合わせ回路の安定待ち（クロックエッジ前）
    if (edge_detected) $display("PASS: Edge detected");
    else begin
      $display("FAIL: Edge not detected");
      $display("  state=%b, data_in=%b, edge_detected=%b", dut.current_state, data_in,
               edge_detected);
    end
    @(posedge clk);  // クロックエッジで状態更新

    // Test 2: 1が継続中はedge_detected=0
    $display("\nTest 2: No edge while data_in stays high");
    @(posedge clk);
    #1;
    if (!edge_detected) $display("PASS: No edge during high");
    else $display("FAIL: Spurious edge detected");

    // Test 3: 1→0 遷移ではedge_detected=0
    $display("\nTest 3: No edge on 1->0 transition");
    @(negedge clk);
    data_in = 0;
    @(posedge clk);
    #1;
    if (!edge_detected) $display("PASS: No edge on falling");
    else $display("FAIL: Edge on falling edge");

    // Test 4: もう一度0→1エッジ
    $display("\nTest 4: Detect second 0->1 edge");
    @(negedge clk);
    data_in = 1;
    #1;
    if (edge_detected) $display("PASS: Second edge detected");
    else $display("FAIL: Second edge not detected");
    @(posedge clk);

    // Test 5: 連続したエッジ
    $display("\nTest 5: Multiple edges");
    @(negedge clk);
    data_in = 0;
    @(negedge clk);
    data_in = 1;
    #1;
    if (edge_detected) $display("PASS: Third edge detected");
    else $display("FAIL: Third edge not detected");
    @(posedge clk);

    repeat (2) @(posedge clk);
    $display("\n=== edge_detector_mealy Test Complete ===");
    $finish;
  end

endmodule
