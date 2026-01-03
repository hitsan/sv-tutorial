// handshake_controller テストベンチ

module handshake_controller_tb;
  logic clk;
  logic rst_n;
  logic start;
  logic ready;
  logic valid;
  logic ack;

  // DUT instantiation
  handshake_controller dut (
      .clk  (clk),
      .rst_n(rst_n),
      .start(start),
      .ready(ready),
      .valid(valid),
      .ack  (ack)
  );

  // Clock generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    $display("=== handshake_controller Test Start ===");

    // Reset
    rst_n = 0;
    start = 0;
    ready = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // Test 1: 基本的なハンドシェイク
    $display("\nTest 1: Basic handshake");
    @(negedge clk);
    start = 1;
    @(negedge clk);
    start = 0;

    // valid確認（Moore型：ACTIVE状態で即座に1）
    @(posedge clk);
    #1;
    if (valid) $display("  PASS: valid asserted (Moore)");
    else $display("  FAIL: valid should be 1");

    if (!ack) $display("  PASS: ack=0 (ready not asserted)");
    else $display("  FAIL: ack should be 0");

    // ready信号をアサート
    @(negedge clk);
    ready = 1;
    #1;

    // ack確認（Mealy型：ready=1と同時に1）
    if (ack) $display("  PASS: ack asserted (Mealy)");
    else $display("  FAIL: ack should be 1");

    @(posedge clk);
    #1;
    ready = 0;

    // DONE状態でvalid=0, ack=0
    if (!valid && !ack) $display("  PASS: valid and ack deasserted");
    else $display("  FAIL: valid=%b, ack=%b should be 0", valid, ack);

    // Test 2: readyが遅れる場合
    $display("\nTest 2: Ready delayed");
    repeat (2) @(posedge clk);  // IDLE状態に戻るまで待つ
    @(negedge clk);
    start = 1;
    @(negedge clk);
    start = 0;

    @(posedge clk);
    #1;
    $display("  Debug: state=%b, valid=%b, ack=%b", dut.state_c, valid, ack);
    if (valid && !ack) $display("  PASS: valid=1, ack=0 (waiting for ready)");
    else $display("  FAIL: valid=%b, ack=%b", valid, ack);

    // 3サイクル待ってからready
    repeat (3) @(posedge clk);
    @(negedge clk);
    ready = 1;
    #1;

    if (valid && ack) $display("  PASS: valid=1, ack=1 (ready received)");
    else $display("  FAIL: valid=%b, ack=%b", valid, ack);

    @(posedge clk);
    ready = 0;

    // Test 3: 連続したハンドシェイク
    $display("\nTest 3: Multiple handshakes");
    repeat (2) @(posedge clk);

    for (int i = 0; i < 3; i++) begin
      @(negedge clk);
      start = 1;
      @(negedge clk);
      start = 0;

      @(posedge clk);
      #1;
      if (valid) $display("  Handshake %0d: valid asserted", i + 1);

      @(negedge clk);
      ready = 1;
      #1;
      if (ack) $display("  Handshake %0d: ack asserted", i + 1);

      @(posedge clk);
      ready = 0;
      @(posedge clk);
    end

    // Test 4: Moore型とMealy型の違いを確認
    $display("\nTest 4: Moore vs Mealy timing");
    repeat (2) @(posedge clk);  // IDLE状態に戻るまで待つ
    @(negedge clk);
    start = 1;
    @(negedge clk);
    start = 0;

    @(posedge clk);  // ACTIVE状態へ遷移
    #1;
    // ACTIVE状態でready=0のとき
    $display("  ACTIVE state, ready=0: valid=%b, ack=%b", valid, ack);
    if (valid && !ack) $display("  PASS: valid=1 (Moore), ack=0 (Mealy needs ready)");
    else $display("  FAIL: valid=%b, ack=%b", valid, ack);

    // readyをアサート（posedgeの前）
    @(negedge clk);
    ready = 1;
    #1;  // 組み合わせ回路の安定待ち（posedge前）
    $display("  ACTIVE state, ready=1: valid=%b, ack=%b", valid, ack);
    if (valid && ack) $display("  PASS: valid=1 (Moore), ack=1 (Mealy)");
    else $display("  FAIL: valid=%b, ack=%b", valid, ack);

    @(posedge clk);
    ready = 0;

    repeat (2) @(posedge clk);
    $display("\n=== handshake_controller Test Complete ===");
    $finish;
  end

endmodule
