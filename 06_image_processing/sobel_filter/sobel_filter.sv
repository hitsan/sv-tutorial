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

  // TODO: 垂直エッジ検出（Gy）

  // TODO: 勾配強度の計算

  // TODO: 飽和処理

endmodule
