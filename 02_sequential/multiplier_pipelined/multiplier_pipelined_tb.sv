// パイプライン乗算器のテストベンチ

`timescale 1ns / 100ps

module multiplier_pipelined_tb;

  // パラメータ
  parameter int INPUT_WIDTH = 8;
  parameter int OUTPUT_WIDTH = INPUT_WIDTH * 2;
  parameter int CLK_PERIOD = 10;

  // 信号
  logic                    clk;
  logic                    rst_n;
  logic [INPUT_WIDTH-1:0]  in0;
  logic [INPUT_WIDTH-1:0]  in1;
  logic [OUTPUT_WIDTH-1:0] product;

  // DUT
  multiplier_pipelined #(
      .INPUT_WIDTH(INPUT_WIDTH),
      .IS_SIGNED(1'b0)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .in0(in0),
      .in1(in1),
      .product(product)
  );

  // クロック生成
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // テストシーケンス
  initial begin
    int errors = 0;

    $display("=================================================");
    $display("Pipelined Multiplier Test");
    $display("=================================================");

    // 初期化
    rst_n = 0;
    in0 = 0;
    in1 = 0;

    // リセット解除
    #(CLK_PERIOD * 2);
    rst_n = 1;
    #(CLK_PERIOD);

    // テストケース
    $display("\n[Test] Pipelined multiplication");

    // 2ステージパイプラインなので、結果は2クロック後に出力される

    // テスト1: 基本的なケース
    in0 = 8'd5;
    in1 = 8'd3;
    #(CLK_PERIOD * 2);  // 2クロック待機
    if (product != 16'd15) begin
      $error("[%0t] Test 1 failed: 5 * 3 = %0d (expected 15)", $time, product);
      errors++;
    end else begin
      $display("[%0t] Test 1 passed: 5 * 3 = %0d", $time, product);
    end
    #(CLK_PERIOD);

    // テスト2: 0との乗算
    in0 = 8'd0;
    in1 = 8'd100;
    #(CLK_PERIOD * 2);
    if (product != 16'd0) begin
      $error("[%0t] Test 2 failed: 0 * 100 = %0d (expected 0)", $time, product);
      errors++;
    end else begin
      $display("[%0t] Test 2 passed: 0 * 100 = %0d", $time, product);
    end
    #(CLK_PERIOD);

    // テスト3: 1との乗算
    in0 = 8'd42;
    in1 = 8'd1;
    #(CLK_PERIOD * 2);
    if (product != 16'd42) begin
      $error("[%0t] Test 3 failed: 42 * 1 = %0d (expected 42)", $time, product);
      errors++;
    end else begin
      $display("[%0t] Test 3 passed: 42 * 1 = %0d", $time, product);
    end
    #(CLK_PERIOD);

    // テスト4: 最大値
    in0 = 8'hFF;
    in1 = 8'hFF;
    #(CLK_PERIOD * 2);
    if (product != 16'hFE01) begin
      $error("[%0t] Test 4 failed: 255 * 255 = %0d (expected %0d)", $time, product, 16'hFE01);
      errors++;
    end else begin
      $display("[%0t] Test 4 passed: 255 * 255 = %0d", $time, product);
    end
    #(CLK_PERIOD);

    // テスト5: べき乗
    in0 = 8'd16;
    in1 = 8'd16;
    #(CLK_PERIOD * 2);
    if (product != 16'd256) begin
      $error("[%0t] Test 5 failed: 16 * 16 = %0d (expected 256)", $time, product);
      errors++;
    end else begin
      $display("[%0t] Test 5 passed: 16 * 16 = %0d", $time, product);
    end
    #(CLK_PERIOD);

    // テスト6: ランダムテスト
    $display("\n[Test] Random test cases");
    for (int i = 0; i < 10; i++) begin
      automatic logic [INPUT_WIDTH-1:0] a = INPUT_WIDTH'($urandom);
      automatic logic [INPUT_WIDTH-1:0] b = INPUT_WIDTH'($urandom);
      automatic logic [OUTPUT_WIDTH-1:0] expected = a * b;

      in0 = a;
      in1 = b;
      #(CLK_PERIOD * 2);

      if (product != expected) begin
        $error("[%0t] Random test %0d failed: %0d * %0d = %0d (expected %0d)",
               $time, i, a, b, product, expected);
        errors++;
      end else begin
        $display("[%0t] Random test %0d passed: %0d * %0d = %0d",
                 $time, i, a, b, product);
      end
      #(CLK_PERIOD);
    end

    // テスト結果
    $display("\n=================================================");
    if (errors == 0) begin
      $display("TEST COMPLETED!");
    end else begin
      $display("TESTS FAILED with %0d errors", errors);
    end
    $display("=================================================");

    $finish;
  end

  // タイムアウト
  initial begin
    #10000;
    $display("TIMEOUT");
    $finish;
  end

endmodule
