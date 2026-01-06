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
      // ラインバッファをシフト
      for (int i = IMAGE_WIDTH - 1; i > 0; i--) begin
        line_buf0[i] <= line_buf0[i-1];
        line_buf1[i] <= line_buf1[i-1];
      end
      line_buf0[0] <= pixel_in;
      line_buf1[0] <= line_buf0[IMAGE_WIDTH-1];
    end
  end
  localparam int WINDOW_SIZE = 3;

  logic [PIXEL_WIDTH-1:0] line_reg[2:0];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 3; i++) begin
        line_reg[i] <= '0;
      end
    end else if (valid_in) begin
      line_reg[0] <= pixel_in;
      line_reg[1] <= line_reg[0];
      line_reg[2] <= line_reg[1];
    end
  end

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
      for (int i = 0; i < IMAGE_WIDTH - 2; i++) begin
        for (int j = 0; j < IMAGE_WIDTH - 2; j++) begin
          window_reg[i][j] <= line_buf0[i];
          window_reg[i][j+1] <= line_buf0[i+1];
          window_reg[i][j+2] <= line_buf0[i+2];
          window_reg[i+1][j] <= line_buf1[i];
          window_reg[i+1][j+1] <= line_buf1[i+1];
          window_reg[i+1][j+2] <= line_buf1[i+2];
          window_reg[i+2][j] <= line_reg[0];
          window_reg[i+2][j+1] <= line_reg[1];
          window_reg[i+2][j+2] <= line_reg[2];
        end
      end
    end
  end
  // TODO: カーネル係数との畳み込み演算
  localparam int CONV_WIDTH = PIXEL_WIDTH + $clog2(PIXEL_WIDTH);
  logic [PIXEL_WIDTH-1:0] accum;
  assign accum = window_reg[0][0]+ window_reg[0][1] + window_reg[0][2] +
    window_reg[1][0]+ window_reg[1][1] + window_reg[1][2] +
    window_reg[2][0]+ window_reg[2][1] + window_reg[2][2];

  // TODO: スケーリング・飽和処理して出力
  assign pixel_out = accum >> SCALE_SHIFT;

  // TODO: ウォームアップ期間を考慮したvalid信号生成
  localparam DELAY_SIZE = WINDOW_SIZE * WINDOW_SIZE;
  logic [DELAY_SIZE-2:0] valid_shift;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) valid_shift <= '0;
    else valid_shift <= {valid_shift[DELAY_SIZE-2:1], valid_in};
  end
  assign valid_out = valid_shift[DELAY_SIZE-2];

endmodule
