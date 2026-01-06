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
  localparam int MUL_WIDTH = DATA_WIDTH + COEFF_WIDTH;
  localparam int ACCUM_WIDTH = MUL_WIDTH + $clog2(NUM_TAPS);
  logic signed [MUL_WIDTH-1:0] mul[NUM_TAPS-1:0];
  logic signed [ACCUM_WIDTH-1:0] accum[NUM_TAPS-1:0];

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
    end else if (valid_in) begin
      accum[0] <= mul[0];
      for (int i = 1; i < NUM_TAPS; i++) begin
        accum[i] <= mul[i] + accum[i-1];
      end
    end
  end

  // TODO: 出力とスケーリング
  localparam int SCALE_SHIFT = 15;
  localparam int SCALED_WIDTH = ACCUM_WIDTH - SCALE_SHIFT;
  logic signed [SCALED_WIDTH-1:0] scaled;
  logic signed [ACCUM_WIDTH-1:0] scaled_full;
  assign scaled_full = accum[NUM_TAPS-1] >>> SCALE_SHIFT;
  assign scaled = scaled_full[SCALED_WIDTH-1:0];

  // 飽和処理の範囲をDATA_WIDTHから計算
  localparam int MAX_DATA = (1 << (DATA_WIDTH - 1)) - 1;
  localparam int MIN_DATA = -(1 << (DATA_WIDTH - 1));

  // 飽和処理（signedデータ値の範囲にクリップ）
  always_comb begin
    if (scaled > SCALED_WIDTH'($signed(MAX_DATA)))
      data_out = MAX_DATA[DATA_WIDTH-1:0];
    else if (scaled < SCALED_WIDTH'($signed(MIN_DATA)))
      data_out = MIN_DATA[DATA_WIDTH-1:0];
    else data_out = scaled[DATA_WIDTH-1:0];
  end

  // TODO: valid信号の遅延
  // 転置形のレイテンシはNUM_TAPSサイクル
  logic [NUM_TAPS-1:0] valid_shift;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_shift <= '0;
    end else begin
      valid_shift <= {valid_shift[NUM_TAPS-2:0], valid_in};
    end
  end
  assign valid_out = valid_shift[NUM_TAPS-1];

endmodule
