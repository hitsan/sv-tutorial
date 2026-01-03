// Greg Stitt
// University of Florida

`timescale 1ns / 100ps

// ALU (Arithmetic Logic Unit)
// - 算術演算、論理演算、シフト演算、比較演算をサポートする汎用演算器
// - opcodeで演算を選択し、2つの入力オペランドに対して演算を実行
// - 結果とともにステータスフラグ（zero, overflow, negative）を出力

import alu_pkg::*;

module alu #(
    parameter  int WIDTH   = 32,
    localparam int SHAMT_W = $clog2(WIDTH)
) (
    input logic [WIDTH-1:0] in0,
    input logic [WIDTH-1:0] in1,
    input alu_op_t opcode,
    output logic [WIDTH-1:0] result,
    output logic zero,
    output logic overflow,
    output logic negative
);
  always_comb begin
    result = '0;
    zero = 1'b0;
    overflow = 1'b0;
    negative = 1'b0;

    case (opcode)
      ALU_ADD: begin
        result   = in0 + in1;
        overflow = (in0[WIDTH-1] == in1[WIDTH-1]) && (result[WIDTH-1] != in0[WIDTH-1]);
      end
      ALU_SUB: begin
        result   = in0 - in1;
        overflow = (in0[WIDTH-1] != in1[WIDTH-1]) && (result[WIDTH-1] != in0[WIDTH-1]);
      end
      ALU_AND: begin
        result = in0 & in1;
      end
      ALU_OR: begin
        result = in0 | in1;
      end
      ALU_XOR: begin
        result = in0 ^ in1;
      end
      ALU_SLL: begin
        result = in0 << in1[SHAMT_W-1:0];
      end
      ALU_SRL: begin
        result = in0 >> in1[SHAMT_W-1:0];
      end
      ALU_SRA: begin
        result = signed'(in0) >>> in1[SHAMT_W-1:0];
      end
      ALU_SLT:  result = {{(WIDTH - 1) {1'b0}}, (signed'(in0) < signed'(in1))};
      ALU_SLTU: result = {{(WIDTH - 1) {1'b0}}, (in0 < in1)};
      default:  ;
    endcase
    negative = result[WIDTH-1];
    zero = (result == '0) ? 1'b1 : 1'b0;
  end
endmodule
