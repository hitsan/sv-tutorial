// Greg Stitt
// University of Florida

`timescale 1ns / 100ps

module alu_tb;
  import alu_pkg::*;

  parameter int WIDTH = 32;
  parameter int NUM_TESTS = 100;

  // 信号の宣言
  logic [WIDTH-1:0] in0, in1;
  alu_op_t opcode;
  logic [WIDTH-1:0] result;
  logic zero, overflow, negative;

  // 期待値
  logic [WIDTH-1:0] expected_result;
  logic expected_zero, expected_overflow, expected_negative;

  // DUT（Design Under Test）のインスタンス化
  alu #(
    .WIDTH(WIDTH)
  ) DUT (
    .in0(in0),
    .in1(in1),
    .opcode(opcode),
    .result(result),
    .zero(zero),
    .overflow(overflow),
    .negative(negative)
  );

  // テストシーケンス
  initial begin
    int errors = 0;

    $display("Starting ALU tests...");

    // 各演算コードに対してテスト
    for (int op = 0; op < 10; op++) begin
      opcode = alu_op_t'(op);

      for (int i = 0; i < NUM_TESTS; i++) begin
        // ランダムな入力を生成
        in0 = $urandom();
        in1 = $urandom();
        #10;

        // 期待値を計算
        case (opcode)
          ALU_ADD: begin
            expected_result = in0 + in1;
            // 符号付き加算のオーバーフロー: 同符号同士を足して異符号になった場合
            expected_overflow = (in0[WIDTH-1] == in1[WIDTH-1]) && (expected_result[WIDTH-1] != in0[WIDTH-1]);
          end
          ALU_SUB: begin
            expected_result = in0 - in1;
            // 符号付き減算のオーバーフロー: 異符号を引いて異符号になった場合
            expected_overflow = (in0[WIDTH-1] != in1[WIDTH-1]) && (expected_result[WIDTH-1] != in0[WIDTH-1]);
          end
          ALU_AND: expected_result = in0 & in1;
          ALU_OR:  expected_result = in0 | in1;
          ALU_XOR: expected_result = in0 ^ in1;
          ALU_SLL: expected_result = in0 << in1[4:0];
          ALU_SRL: expected_result = in0 >> in1[4:0];
          ALU_SRA: expected_result = $signed(in0) >>> in1[4:0];
          ALU_SLT: expected_result = {{(WIDTH-1){1'b0}}, ($signed(in0) < $signed(in1))};
          ALU_SLTU: expected_result = {{(WIDTH-1){1'b0}}, (in0 < in1)};
          default: expected_result = '0;
        endcase

        expected_zero = (expected_result == 0);
        expected_negative = expected_result[WIDTH-1];

        // 結果を検証
        if (result !== expected_result) begin
          $error("[%0t] %s: result mismatch - in0=%h, in1=%h, got=%h, expected=%h",
                 $realtime, opcode.name(), in0, in1, result, expected_result);
          errors++;
        end

        if (zero !== expected_zero) begin
          $error("[%0t] %s: zero flag mismatch - got=%b, expected=%b",
                 $realtime, opcode.name(), zero, expected_zero);
          errors++;
        end

        if (negative !== expected_negative && (opcode == ALU_ADD || opcode == ALU_SUB ||
            opcode == ALU_AND || opcode == ALU_OR || opcode == ALU_XOR ||
            opcode == ALU_SLL || opcode == ALU_SRA)) begin
          $error("[%0t] %s: negative flag mismatch - got=%b, expected=%b",
                 $realtime, opcode.name(), negative, expected_negative);
          errors++;
        end

        if ((opcode == ALU_ADD || opcode == ALU_SUB) && (overflow !== expected_overflow)) begin
          $error("[%0t] %s: overflow flag mismatch - in0=%h, in1=%h, result=%h, got=%b, expected=%b",
                 $realtime, opcode.name(), in0, in1, result, overflow, expected_overflow);
          errors++;
        end
      end
    end

    if (errors == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Tests failed with %0d errors", errors);
    end

    $finish;
  end

endmodule
