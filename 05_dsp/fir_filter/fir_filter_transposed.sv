//============================================================================
// File: fir_filter_transposed.sv
// Description: 4タップFIRフィルタ - 転置形II構造 (Transposed Form II)
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns / 1ps

module fir_filter_transposed #(
    parameter int DATA_WIDTH = 16,
    parameter int COEFF_WIDTH = 16,
    parameter int NUM_TAPS = 4,
    // フィルタ係数（Q1.15形式）
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_0 = 16'sh2000,  // 0.25
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_1 = 16'sh4000,  // 0.5
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_2 = 16'sh4000,  // 0.5
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_3 = 16'sh2000  // 0.25
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic signed [DATA_WIDTH-1:0] data_in,
    input  logic                         valid_in,
    output logic signed [DATA_WIDTH-1:0] data_out,
    output logic                         valid_out
);

  // 転置形の構造:
  // 入力 → 各係数と乗算 → 加算器チェーン → 出力
  //                ↑
  //             レジスタ（加算結果を保持）
  //
  // 直接形との違い:
  // - 直接形: シフトレジスタ → 乗算 → 加算
  // - 転置形: 乗算 → 加算 → レジスタチェーン
  //
  // 利点: クリティカルパス = 1乗算 + 1加算（直接形は1乗算 + N-1加算）

  // TODO: 内部信号定義
  localparam int MUL_WIDTH = DATA_WIDTH * 2;
  logic signed [MUL_WIDTH-1:0] mul  [NUM_TAPS-1:0];
  logic signed [MUL_WIDTH-1:0] accum[NUM_TAPS-1:0];

  // TODO: 乗算
  always_comb begin
    mul[0] = data_in * COEFF_0;
    mul[1] = data_in * COEFF_1;
    mul[2] = data_in * COEFF_2;
    mul[3] = data_in * COEFF_3;
  end

  // TODO: 転置形の加算器チェーン
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < NUM_TAPS; i++) accum[i] <= '0;
    end else begin
      accum[0] <= mul[0];
      for (int i = 1; i < NUM_TAPS; i++) begin
        accum[i] <= mul[i] + accum[i-1];
      end
    end
  end

  // TODO: 出力とスケーリング
  assign data_out = 16'(accum[NUM_TAPS-1] >> 15);

  // TODO: valid信号の遅延
  logic [NUM_TAPS-2:0] valid_reg;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!valid_in) valid_out = '0;
    else begin
      valid_reg[0] <= valid_in;
      for (int i = 1; i < NUM_TAPS - 2; i++) begin
        valid_reg[i] <= valid_reg[i-1];
      end
      valid_out <= valid_reg[NUM_TAPS-2];
    end
  end

endmodule
