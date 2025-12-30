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

    // TODO: テストケースを追加
    // 注意: 2ステージパイプラインなので、結果は2クロック後に出力される

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
