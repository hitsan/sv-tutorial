// シフトレジスタのテストベンチ

`timescale 1ns / 100ps

module shift_register_tb;

  // クロックとリセット
  logic clk;
  logic rst_n;

  // パラメータ
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;  // 10ns = 100MHz

  // ============================================================================
  // テスト1: 右シフトレジスタ
  // ============================================================================
  logic sr_right_serial_in, sr_right_serial_out;
  logic [WIDTH-1:0] sr_right_parallel_out;

  shift_reg_right #(.WIDTH(WIDTH)) dut_right (
      .clk(clk),
      .rst_n(rst_n),
      .serial_in(sr_right_serial_in),
      .serial_out(sr_right_serial_out),
      .parallel_out(sr_right_parallel_out)
  );

  // ============================================================================
  // テスト2: 左シフトレジスタ
  // ============================================================================
  logic sr_left_serial_in, sr_left_serial_out;
  logic [WIDTH-1:0] sr_left_parallel_out;

  shift_reg_left #(.WIDTH(WIDTH)) dut_left (
      .clk(clk),
      .rst_n(rst_n),
      .serial_in(sr_left_serial_in),
      .serial_out(sr_left_serial_out),
      .parallel_out(sr_left_parallel_out)
  );

  // ============================================================================
  // テスト3: PISOシフトレジスタ
  // ============================================================================
  logic piso_load, piso_serial_in, piso_serial_out;
  logic [WIDTH-1:0] piso_parallel_in;

  shift_reg_piso #(.WIDTH(WIDTH)) dut_piso (
      .clk(clk),
      .rst_n(rst_n),
      .load(piso_load),
      .parallel_in(piso_parallel_in),
      .serial_in(piso_serial_in),
      .serial_out(piso_serial_out)
  );

  // ============================================================================
  // テスト4: 双方向シフトレジスタ
  // ============================================================================
  logic bidir_dir, bidir_serial_in_right, bidir_serial_in_left;
  logic bidir_serial_out_right, bidir_serial_out_left;
  logic [WIDTH-1:0] bidir_parallel_out;

  shift_reg_bidirectional #(.WIDTH(WIDTH)) dut_bidir (
      .clk(clk),
      .rst_n(rst_n),
      .dir(bidir_dir),
      .serial_in_right(bidir_serial_in_right),
      .serial_in_left(bidir_serial_in_left),
      .serial_out_right(bidir_serial_out_right),
      .serial_out_left(bidir_serial_out_left),
      .parallel_out(bidir_parallel_out)
  );

  // ============================================================================
  // テスト5: ユニバーサルシフトレジスタ
  // ============================================================================
  logic [1:0] univ_mode;
  logic univ_serial_in_right, univ_serial_in_left;
  logic univ_serial_out_right, univ_serial_out_left;
  logic [WIDTH-1:0] univ_parallel_in, univ_parallel_out;

  shift_reg_universal #(.WIDTH(WIDTH)) dut_univ (
      .clk(clk),
      .rst_n(rst_n),
      .mode(univ_mode),
      .serial_in_right(univ_serial_in_right),
      .serial_in_left(univ_serial_in_left),
      .parallel_in(univ_parallel_in),
      .serial_out_right(univ_serial_out_right),
      .serial_out_left(univ_serial_out_left),
      .parallel_out(univ_parallel_out)
  );

  // ============================================================================
  // テスト6: リングカウンタ
  // ============================================================================
  logic [WIDTH-1:0] ring_out;

  shift_reg_ring #(.WIDTH(WIDTH)) dut_ring (
      .clk(clk),
      .rst_n(rst_n),
      .ring_out(ring_out)
  );

  // ============================================================================
  // クロック生成
  // ============================================================================
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // ============================================================================
  // テストシーケンス
  // ============================================================================
  initial begin
    int errors = 0;

    $display("=================================================");
    $display("Shift Register Test Suite");
    $display("=================================================");

    // 初期化
    rst_n = 0;
    sr_right_serial_in = 0;
    sr_left_serial_in = 0;
    piso_load = 0;
    piso_parallel_in = 0;
    piso_serial_in = 0;
    bidir_dir = 1;
    bidir_serial_in_right = 0;
    bidir_serial_in_left = 0;
    univ_mode = 2'b00;
    univ_serial_in_right = 0;
    univ_serial_in_left = 0;
    univ_parallel_in = 0;

    // リセット解除
    #(CLK_PERIOD * 2);
    rst_n = 1;
    #(CLK_PERIOD);

    // -----------------------------------------------------------------
    // テスト1: 右シフトレジスタ
    // -----------------------------------------------------------------
    $display("\n[Test 1] Right Shift Register");
    sr_right_serial_in = 1;
    @(posedge clk);
    sr_right_serial_in = 0;
    repeat(WIDTH) @(posedge clk);
    #1;
    $display("  Parallel out: 0x%h (expected pattern with single 1)", sr_right_parallel_out);

    // -----------------------------------------------------------------
    // テスト2: 左シフトレジスタ
    // -----------------------------------------------------------------
    $display("\n[Test 2] Left Shift Register");
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    sr_left_serial_in = 1;
    @(posedge clk);
    sr_left_serial_in = 0;
    repeat(WIDTH) @(posedge clk);
    #1;
    $display("  Parallel out: 0x%h (expected pattern with single 1)", sr_left_parallel_out);

    // -----------------------------------------------------------------
    // テスト3: PISOシフトレジスタ
    // -----------------------------------------------------------------
    $display("\n[Test 3] PISO Shift Register");
    piso_parallel_in = 8'hA5;
    piso_load = 1;
    @(posedge clk);
    piso_load = 0;
    #1;
    $display("  After load: serial_out = %b", piso_serial_out);
    repeat(WIDTH) begin
      @(posedge clk);
      #1;
      $display("  Shifted: serial_out = %b", piso_serial_out);
    end

    // -----------------------------------------------------------------
    // テスト4: 双方向シフトレジスタ
    // -----------------------------------------------------------------
    $display("\n[Test 4] Bidirectional Shift Register");
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;

    // 右シフトテスト
    bidir_dir = 1;
    bidir_serial_in_right = 1;
    repeat(3) @(posedge clk);
    #1;
    $display("  After 3 right shifts: 0x%h", bidir_parallel_out);

    // 左シフトテスト
    bidir_dir = 0;
    bidir_serial_in_left = 1;
    repeat(3) @(posedge clk);
    #1;
    $display("  After 3 left shifts: 0x%h", bidir_parallel_out);

    // -----------------------------------------------------------------
    // テスト5: ユニバーサルシフトレジスタ
    // -----------------------------------------------------------------
    $display("\n[Test 5] Universal Shift Register");

    // パラレルロード
    univ_mode = 2'b11;
    univ_parallel_in = 8'hF0;
    @(posedge clk);
    #1;
    $display("  After parallel load: 0x%h", univ_parallel_out);

    // ホールド
    univ_mode = 2'b00;
    @(posedge clk);
    #1;
    $display("  After hold: 0x%h (should be same)", univ_parallel_out);

    // 右シフト
    univ_mode = 2'b01;
    repeat(2) @(posedge clk);
    #1;
    $display("  After 2 right shifts: 0x%h", univ_parallel_out);

    // 左シフト
    univ_mode = 2'b10;
    repeat(2) @(posedge clk);
    #1;
    $display("  After 2 left shifts: 0x%h", univ_parallel_out);

    // -----------------------------------------------------------------
    // テスト6: リングカウンタ
    // -----------------------------------------------------------------
    $display("\n[Test 6] Ring Counter");
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    #1;
    $display("  Initial: 0x%h", ring_out);
    repeat(WIDTH + 2) begin
      @(posedge clk);
      #1;
      $display("  Ring: 0x%h", ring_out);
    end

    // -----------------------------------------------------------------
    // テスト結果サマリー
    // -----------------------------------------------------------------
    $display("\n=================================================");
    if (errors == 0) begin
      $display("ALL TESTS COMPLETED!");
      $display("(Manual verification required)");
    end else begin
      $display("TESTS FAILED with %0d errors", errors);
    end
    $display("=================================================");

    $finish;
  end

  // タイムアウト
  initial begin
    #50000;
    $display("TIMEOUT: Test took too long");
    $finish;
  end

endmodule
