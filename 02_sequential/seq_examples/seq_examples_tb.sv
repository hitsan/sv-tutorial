// 順序回路演習のテストベンチ

`timescale 1ns / 100ps

module seq_examples_tb;

  // クロックとリセット
  logic clk;
  logic rst_n;

  // テスト用のパラメータ
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;  // 10ns = 100MHz

  // ============================================================================
  // クロック生成
  // ============================================================================
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // ============================================================================
  // 演習1: D型フリップフロップのテスト
  // ============================================================================
  logic [WIDTH-1:0] ex1_d, ex1_q;

  exercise1_dff #(
      .WIDTH(WIDTH)
  ) ex1_dut (
      .clk(clk),
      .rst_n(rst_n),
      .d(ex1_d),
      .q(ex1_q)
  );

  // ============================================================================
  // 演習2: イネーブル付きレジスタのテスト
  // ============================================================================
  logic ex2_en;
  logic [WIDTH-1:0] ex2_d, ex2_q;

  exercise2_enable_reg #(
      .WIDTH(WIDTH)
  ) ex2_dut (
      .clk(clk),
      .rst_n(rst_n),
      .en(ex2_en),
      .d(ex2_d),
      .q(ex2_q)
  );

  // ============================================================================
  // 演習3: パイプラインレジスタのテスト
  // ============================================================================
  logic [WIDTH-1:0] ex3_d, ex3_q;

  exercise3_pipeline #(
      .WIDTH(WIDTH)
  ) ex3_dut (
      .clk(clk),
      .rst_n(rst_n),
      .d(ex3_d),
      .q(ex3_q)
  );

  // ============================================================================
  // 演習4: シフトレジスタのテスト
  // ============================================================================
  logic ex4_serial_in, ex4_serial_out;
  logic [WIDTH-1:0] ex4_parallel_out;

  exercise4_shift_reg #(
      .WIDTH(WIDTH)
  ) ex4_dut (
      .clk(clk),
      .rst_n(rst_n),
      .serial_in(ex4_serial_in),
      .serial_out(ex4_serial_out),
      .parallel_out(ex4_parallel_out)
  );

  // ============================================================================
  // 演習5: アップカウンタのテスト
  // ============================================================================
  logic [WIDTH-1:0] ex5_count;

  exercise5_counter #(
      .WIDTH(WIDTH)
  ) ex5_dut (
      .clk  (clk),
      .rst_n(rst_n),
      .count(ex5_count)
  );

  // ============================================================================
  // 演習6: アップ/ダウンカウンタのテスト
  // ============================================================================
  logic ex6_en, ex6_up;
  logic [WIDTH-1:0] ex6_count;

  exercise6_updown_counter #(
      .WIDTH(WIDTH)
  ) ex6_dut (
      .clk(clk),
      .rst_n(rst_n),
      .en(ex6_en),
      .up(ex6_up),
      .count(ex6_count)
  );

  // ============================================================================
  // テストシーケンス
  // ============================================================================
  initial begin
    int errors = 0;

    $display("=================================================");
    $display("Sequential Circuit Examples Test");
    $display("=================================================");

    // 初期化
    rst_n = 0;
    ex1_d = 0;
    ex2_en = 0;
    ex2_d = 0;
    ex3_d = 0;
    ex4_serial_in = 0;
    ex6_en = 0;
    ex6_up = 1;

    // リセット解除
    #(CLK_PERIOD * 2);
    rst_n = 1;
    #(CLK_PERIOD);

    // -----------------------------------------------------------------
    // 演習1: D型フリップフロップのテスト
    // -----------------------------------------------------------------
    $display("\n[Test 1] D Flip-Flop");
    ex1_d = 8'hAA;
    @(posedge clk);
    #1;  // クロックエッジ後の遅延
    if (ex1_q !== 8'hAA) begin
      $error("  FAIL: Expected q=0xAA, got q=0x%h", ex1_q);
      errors++;
    end else begin
      $display("  PASS: q correctly updated to 0x%h", ex1_q);
    end

    ex1_d = 8'h55;
    @(posedge clk);
    #1;
    if (ex1_q !== 8'h55) begin
      $error("  FAIL: Expected q=0x55, got q=0x%h", ex1_q);
      errors++;
    end else begin
      $display("  PASS: q correctly updated to 0x%h", ex1_q);
    end

    // -----------------------------------------------------------------
    // 演習2: イネーブル付きレジスタのテスト
    // -----------------------------------------------------------------
    $display("\n[Test 2] Enable Register");
    ex2_d  = 8'h12;
    ex2_en = 1;
    @(posedge clk);
    #1;
    if (ex2_q !== 8'h12) begin
      $error("  FAIL: Expected q=0x12 when en=1, got q=0x%h", ex2_q);
      errors++;
    end else begin
      $display("  PASS: q updated to 0x%h when en=1", ex2_q);
    end

    ex2_d  = 8'h34;
    ex2_en = 0;  // イネーブル無効
    @(posedge clk);
    #1;
    if (ex2_q !== 8'h12) begin  // 前の値を保持
      $error("  FAIL: Expected q=0x12 when en=0, got q=0x%h", ex2_q);
      errors++;
    end else begin
      $display("  PASS: q held at 0x%h when en=0", ex2_q);
    end

    // -----------------------------------------------------------------
    // 演習3: パイプラインレジスタのテスト
    // -----------------------------------------------------------------
    $display("\n[Test 3] Pipeline Register (2 stages)");
    ex3_d = 8'hFF;
    @(posedge clk);
    #1;
    $display("  After 1 clk: d=0x%h, q=0x%h (expected q=0x00)", ex3_d, ex3_q);

    @(posedge clk);
    #1;
    if (ex3_q !== 8'hFF) begin
      $error("  FAIL: Expected 2-cycle delay, got q=0x%h", ex3_q);
      errors++;
    end else begin
      $display("  PASS: 2-cycle delay confirmed, q=0x%h", ex3_q);
    end

    // -----------------------------------------------------------------
    // 演習4: シフトレジスタのテスト
    // -----------------------------------------------------------------
    $display("\n[Test 4] Shift Register");
    // パターン 10101010 を1ビットずつ入力
    for (int i = 0; i < WIDTH; i++) begin
      ex4_serial_in = i[0];  // 交互に0と1
      @(posedge clk);
    end
    #1;
    $display("  Parallel output: 0x%h (expected pattern)", ex4_parallel_out);

    // -----------------------------------------------------------------
    // 演習5: アップカウンタのテスト
    // -----------------------------------------------------------------
    $display("\n[Test 5] Up Counter");
    rst_n = 0;
    @(posedge clk);
    #1;
    rst_n = 1;

    for (int i = 0; i < 5; i++) begin
      @(posedge clk);
      #1;
      if (ex5_count !== 8'(i + 1)) begin
        $error("  FAIL: Expected count=%0d, got count=%0d", i + 1, ex5_count);
        errors++;
      end
    end
    $display("  PASS: Counter incremented correctly to %0d", ex5_count);

    // -----------------------------------------------------------------
    // 演習6: アップ/ダウンカウンタのテスト
    // -----------------------------------------------------------------
    $display("\n[Test 6] Up/Down Counter");
    rst_n = 0;
    @(posedge clk);
    #1;
    rst_n  = 1;
    ex6_en = 1;
    ex6_up = 1;

    // カウントアップ
    for (int i = 0; i < 3; i++) begin
      @(posedge clk);
    end
    #1;
    $display("  After 3 up counts: %0d", ex6_count);

    // カウントダウン
    ex6_up = 0;
    for (int i = 0; i < 2; i++) begin
      @(posedge clk);
    end
    #1;
    $display("  After 2 down counts: %0d", ex6_count);

    // イネーブル無効
    ex6_en = 0;
    @(posedge clk);
    #1;
    if (ex6_count !== 8'd1) begin  // 3 up - 2 down = 1
      $error("  FAIL: Count changed when en=0");
      errors++;
    end else begin
      $display("  PASS: Count held at %0d when en=0", ex6_count);
    end

    // -----------------------------------------------------------------
    // テスト結果サマリー
    // -----------------------------------------------------------------
    $display("\n=================================================");
    if (errors == 0) begin
      $display("ALL TESTS PASSED!");
    end else begin
      $display("TESTS FAILED with %0d errors", errors);
    end
    $display("=================================================");

    $finish;
  end

  // タイムアウト（無限ループ防止）
  initial begin
    #10000;
    $display("TIMEOUT: Test took too long");
    $finish;
  end

endmodule
