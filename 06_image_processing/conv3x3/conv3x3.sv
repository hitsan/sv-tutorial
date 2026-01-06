//============================================================================
// File: conv3x3.sv
// Description: 3x3畳み込み演算モジュール（ストリーミング処理）
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns / 1ps

module conv3x3 #(
    parameter int PIXEL_WIDTH = 8,  // ピクセルデータのビット幅
    parameter int IMAGE_WIDTH = 8,  // 画像幅（ピクセル数）
    parameter int COEFF_WIDTH = 8,  // カーネル係数のビット幅
    // カーネル係数（デフォルト: 3x3平滑化フィルタ）
    parameter logic signed [COEFF_WIDTH-1:0] K00 = 1,
    K01 = 1,
    K02 = 1,
    parameter logic signed [COEFF_WIDTH-1:0] K10 = 1,
    K11 = 1,
    K12 = 1,
    parameter logic signed [COEFF_WIDTH-1:0] K20 = 1,
    K21 = 1,
    K22 = 1,
    parameter int SCALE_SHIFT = 0  // スケーリング用の右シフト量
) (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic        [PIXEL_WIDTH-1:0] pixel_in,
    input  logic                          valid_in,
    output logic signed [PIXEL_WIDTH-1:0] pixel_out,
    output logic                          valid_out
);

  // TODO: 2行分のラインバッファとウィンドウレジスタ
  logic [PIXEL_WIDTH-1:0] line_buf0[0:IMAGE_WIDTH-1];
  logic [PIXEL_WIDTH-1:0] line_buf1[0:IMAGE_WIDTH-1];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < IMAGE_WIDTH; i++) begin
        line_buf0[i] <= '0;
        line_buf1[i] <= '0;
      end
    end else if (valid_in) begin
      for (int i = IMAGE_WIDTH - 1; i > 0; i--) begin
        line_buf0[i] <= line_buf0[i-1];
        line_buf1[i] <= line_buf1[i-1];
      end
      line_buf0[0] <= pixel_in;
      line_buf1[0] <= line_buf0[IMAGE_WIDTH-1];
    end
  end
  localparam int WINDOW_SIZE = 3;

  // TODO: 入力ストリームから3x3ウィンドウを構成
  logic [PIXEL_WIDTH-1:0] window_reg[WINDOW_SIZE-1:0][WINDOW_SIZE-1:0];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < WINDOW_SIZE; i++) begin
        for (int j = 0; j < WINDOW_SIZE; j++) begin
          window_reg[i][j] <= '0;
        end
      end
    end else if (valid_in) begin
      window_reg[0][0] <= window_reg[0][1];
      window_reg[0][1] <= window_reg[0][2];
      window_reg[0][2] <= line_buf1[IMAGE_WIDTH-1];

      window_reg[1][0] <= window_reg[1][1];
      window_reg[1][1] <= window_reg[1][2];
      window_reg[1][2] <= line_buf0[IMAGE_WIDTH-1];

      window_reg[2][0] <= window_reg[2][1];
      window_reg[2][1] <= window_reg[2][2];
      window_reg[2][2] <= pixel_in;
    end
  end
  // カーネル係数との畳み込み演算
  localparam int CONV_WIDTH = PIXEL_WIDTH + COEFF_WIDTH + 4;
  logic signed [CONV_WIDTH-1:0] sum;

  assign sum = $signed(
      {1'b0, window_reg[0][0]}
  ) * K00 + $signed(
      {1'b0, window_reg[0][1]}
  ) * K01 + $signed(
      {1'b0, window_reg[0][2]}
  ) * K02 + $signed(
      {1'b0, window_reg[1][0]}
  ) * K10 + $signed(
      {1'b0, window_reg[1][1]}
  ) * K11 + $signed(
      {1'b0, window_reg[1][2]}
  ) * K12 + $signed(
      {1'b0, window_reg[2][0]}
  ) * K20 + $signed(
      {1'b0, window_reg[2][1]}
  ) * K21 + $signed(
      {1'b0, window_reg[2][2]}
  ) * K22;

  // スケーリング・飽和処理して出力
  logic signed [CONV_WIDTH-1:0] scaled;
  assign scaled = sum >>> SCALE_SHIFT;

  // 飽和処理（-128〜127の範囲にクリップ）
  always_comb begin
    if (scaled > 127) pixel_out = 127;
    else if (scaled < -128) pixel_out = -128;
    else pixel_out = scaled[PIXEL_WIDTH-1:0];
  end

  // ウォームアップ期間を考慮したvalid信号生成
  localparam int WARMUP_CYCLES = 2 * IMAGE_WIDTH + 3;
  int pixel_count;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pixel_count <= '0;
    end else if (valid_in) begin
      if (pixel_count < WARMUP_CYCLES) pixel_count <= pixel_count + 1;
    end
  end

  assign valid_out = valid_in && (pixel_count >= WARMUP_CYCLES);

endmodule
