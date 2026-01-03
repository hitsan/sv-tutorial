// Greg Stitt
// University of Florida

`timescale 1ns / 100ps

module multiplier_tb;

  // TODO: パラメータを定義
  // - テスト回数（NUM_TESTS）
  // - 入力ビット幅（INPUT_WIDTH）
  parameter int NUM_TESTS = 1000;
  parameter int INPUT_WIDTH = 8;
  parameter int OUTPUT_WIDTH = INPUT_WIDTH * 2;

  // 信号を宣言
  logic [INPUT_WIDTH-1:0] in0, in1;
  logic [OUTPUT_WIDTH-1:0] product_signed, product_unsigned;

  // DUTをインスタンス化
  multiplier #(
      .IS_SIGNED  (1'b1),
      .INPUT_WIDTH(INPUT_WIDTH)
  ) DUT_SIGNED (
      .product(product_signed),
      .*
  );

  multiplier #(
      .IS_SIGNED  (1'b0),
      .INPUT_WIDTH(INPUT_WIDTH)
  ) DUT_UNSIGNED (
      .product(product_unsigned),
      .*
  );

  // テストシーケンス
  initial begin
    logic [OUTPUT_WIDTH-1:0] correct_product_signed, correct_product_unsigned;

    for (int i = 0; i < NUM_TESTS; i++) begin
      // ランダムな入力を生成
      in0 = $urandom;
      in1 = $urandom;
      #10;

      // 期待値を計算
      correct_product_signed   = signed'(in0) * signed'(in1);
      correct_product_unsigned = in0 * in1;

      // signed版の検証
      if (product_signed != correct_product_signed)
        $error(
            "[%0t] signed: got %d, expected %d", $realtime, product_signed, correct_product_signed
        );

      // unsigned版の検証
      if (product_unsigned != correct_product_unsigned)
        $error(
            "[%0t] unsigned: got %d, expected %d",
            $realtime,
            product_unsigned,
            correct_product_unsigned
        );
    end

    $display("Tests completed.");
    $finish;
  end

endmodule
