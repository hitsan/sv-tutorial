//============================================================================
// File: sobel_filter.sv
// Description: Sobelエッジ検出フィルタ（構造記述による実装）
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns / 1ps

module sobel_filter #(
    parameter int PIXEL_WIDTH = 8,
    parameter int IMAGE_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [PIXEL_WIDTH-1:0] pixel_in,
    input  logic                   valid_in,
    output logic [PIXEL_WIDTH-1:0] edge_out,
    output logic                   valid_out
);
  // Sobelカーネル
  // Gx (水平エッジ):        Gy (垂直エッジ):
  // [-1  0  +1]             [-1 -2 -1]
  // [-2  0  +2]             [ 0  0  0]
  // [-1  0  +1]             [+1 +2 +1]

  // TODO: 水平エッジ検出（Gx）
  logic signed [PIXEL_WIDTH-1:0] gx_out;
  logic valid_gx_out;
  conv3x3 #(
      .PIXEL_WIDTH(PIXEL_WIDTH),
      .IMAGE_WIDTH(IMAGE_WIDTH),
      .COEFF_WIDTH(8),
      .K00(-8'sd1),
      .K01(8'sd0),
      .K02(8'sd1),
      .K10(-8'sd2),
      .K11(8'sd0),
      .K12(8'sd2),
      .K20(-8'sd1),
      .K21(8'sd0),
      .K22(8'sd1),
      .SCALE_SHIFT(0)
  ) gx (
      .clk(clk),
      .rst_n(rst_n),
      .pixel_in(pixel_in),
      .valid_in(valid_in),
      .pixel_out(gx_out),
      .valid_out(valid_gx_out)
  );

  // TODO: 垂直エッジ検出（Gy）
  logic signed [PIXEL_WIDTH-1:0] gy_out;
  logic valid_gy_out;
  conv3x3 #(
      .PIXEL_WIDTH(PIXEL_WIDTH),
      .IMAGE_WIDTH(IMAGE_WIDTH),
      .COEFF_WIDTH(8),
      .K00(-8'sd1),
      .K01(-8'sd2),
      .K02(-8'sd1),
      .K10(8'sd0),
      .K11(8'sd0),
      .K12(8'sd0),
      .K20(8'sd1),
      .K21(8'sd2),
      .K22(8'sd1),
      .SCALE_SHIFT(0)
  ) gy (
      .clk(clk),
      .rst_n(rst_n),
      .pixel_in(pixel_in),
      .valid_in(valid_in),
      .pixel_out(gy_out),
      .valid_out(valid_gy_out)
  );

  // TODO: 勾配強度の計算
  logic [  PIXEL_WIDTH:0] gradient;
  logic [PIXEL_WIDTH-1:0] gx_abs;
  logic [PIXEL_WIDTH-1:0] gy_abs;
  always_comb begin
    gx_abs   = (gx_out < 0) ? -gx_out : gx_out;
    gy_abs   = (gy_out < 0) ? -gy_out : gy_out;
    gradient = gx_abs + gy_abs;
  end
  // TODO: 飽和処理
  assign edge_out  = (gradient > 255) ? 8'd255 : gradient[PIXEL_WIDTH-1:0];

  assign valid_out = valid_gx_out & valid_gy_out;

endmodule
