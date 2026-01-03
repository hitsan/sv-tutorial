// Greg Stitt
// University of Florida

`timescale 1ns / 100ps

// ALU パッケージ
// - ALU関連の型定義と定数を提供
// - 複数のモジュール（ALU本体、テストベンチなど）で共有

package alu_pkg;

  typedef enum logic [3:0] {
    ALU_ADD  = 4'b0000,
    ALU_SUB  = 4'b0001,
    ALU_AND  = 4'b0010,
    ALU_OR   = 4'b0011,
    ALU_XOR  = 4'b0100,
    ALU_SLL  = 4'b0101,
    ALU_SRL  = 4'b0110,
    ALU_SRA  = 4'b0111,
    ALU_SLT  = 4'b1000,
    ALU_SLTU = 4'b1001
  } alu_op_t;
endpackage
