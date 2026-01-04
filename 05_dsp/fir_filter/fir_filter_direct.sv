//============================================================================
// File: fir_filter_direct.sv
// Description: 4タップFIRフィルタ - 直接形I構造 (Direct Form I)
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns / 1ps

module fir_filter_direct #(
    parameter int DATA_WIDTH = 16,  // 入力データのビット幅
    parameter int COEFF_WIDTH = 16,  // 係数のビット幅
    parameter int NUM_TAPS = 4,  // タップ数（固定）
    // フィルタ係数（Q1.15形式の例：0.25, 0.5, 0.5, 0.25）
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

  // TODO: 内部信号定義
  logic signed [  DATA_WIDTH-1:0] shift_reg[0:NUM_TAPS-1];
  logic signed [DATA_WIDTH*2-1:0] accum;
  // TODO: シフトレジスタ（遅延線）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < NUM_TAPS; i++) begin
        shift_reg[i] <= '0;
      end
    end else begin
      shift_reg[0] <= data_in;
      for (int i = 1; i < NUM_TAPS; i++) begin
        shift_reg[i] <= shift_reg[i-1];
      end
    end
  end

  // TODO: MAC演算（Multiply-Accumulate）
  // 各タップの係数とサンプルを乗算し、すべてを加算
  assign accum = COEFF_0 * shift_reg[0] + COEFF_1 * shift_reg[1] + COEFF_2 * shift_reg[2] + COEFF_3 * shift_reg[3];

  // TODO: 出力（スケーリング）
  // Q1.15 * Q1.15 = Q2.30 なので、15ビット右シフトでQ1.15に戻す
  assign data_out = 16'(accum >> 15);

  // TODO: valid信号の遅延（1サイクルのレイテンシ）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) valid_out <= 1'b0;
    else valid_out <= valid_in;
  end
endmodule
