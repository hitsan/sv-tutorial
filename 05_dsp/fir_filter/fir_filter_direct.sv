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
  logic signed [DATA_WIDTH-1:0] shift_reg[0:NUM_TAPS-1];

  // 累算器のビット幅: DATA + COEFF + log2(NUM_TAPS)
  localparam int ACCUM_WIDTH = DATA_WIDTH + COEFF_WIDTH + $clog2(NUM_TAPS);
  logic signed [ACCUM_WIDTH-1:0] accum;
  // TODO: シフトレジスタ（遅延線）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < NUM_TAPS; i++) begin
        shift_reg[i] <= '0;
      end
    end else if (valid_in) begin
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
  localparam int SCALE_SHIFT = 15;
  localparam int SCALED_WIDTH = ACCUM_WIDTH - SCALE_SHIFT;
  logic signed [SCALED_WIDTH-1:0] scaled;
  logic signed [ ACCUM_WIDTH-1:0] scaled_full;
  assign scaled_full = accum >>> SCALE_SHIFT;
  assign scaled = scaled_full[SCALED_WIDTH-1:0];

  // 飽和処理の範囲をDATA_WIDTHから計算
  localparam int MAX_DATA = (1 << (DATA_WIDTH - 1)) - 1;  // 2^(N-1) - 1
  localparam int MIN_DATA = -(1 << (DATA_WIDTH - 1));  // -2^(N-1)

  // 飽和処理（signedデータ値の範囲にクリップ）
  always_comb begin
    if (scaled > SCALED_WIDTH'($signed(MAX_DATA))) data_out = MAX_DATA[DATA_WIDTH-1:0];
    else if (scaled < SCALED_WIDTH'($signed(MIN_DATA))) data_out = MIN_DATA[DATA_WIDTH-1:0];
    else data_out = scaled[DATA_WIDTH-1:0];
  end

  // TODO: valid信号の遅延（1サイクルのレイテンシ）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) valid_out <= 1'b0;
    else valid_out <= valid_in;
  end
endmodule
