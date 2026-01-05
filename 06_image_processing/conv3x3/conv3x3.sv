//============================================================================
// File: conv3x3.sv
// Description: 3x3畳み込み演算モジュール（ストリーミング処理）
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

module conv3x3 #(
    parameter int PIXEL_WIDTH = 8,      // ピクセルデータのビット幅
    parameter int IMAGE_WIDTH = 8,      // 画像幅（ピクセル数）
    parameter int COEFF_WIDTH = 8,      // カーネル係数のビット幅
    // カーネル係数（デフォルト: 3x3平滑化フィルタ）
    parameter logic signed [COEFF_WIDTH-1:0] K00 = 1, K01 = 1, K02 = 1,
    parameter logic signed [COEFF_WIDTH-1:0] K10 = 1, K11 = 1, K12 = 1,
    parameter logic signed [COEFF_WIDTH-1:0] K20 = 1, K21 = 1, K22 = 1,
    parameter int SCALE_SHIFT = 0       // スケーリング用の右シフト量
) (
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic [PIXEL_WIDTH-1:0]      pixel_in,
    input  logic                        valid_in,
    output logic signed [PIXEL_WIDTH-1:0] pixel_out,
    output logic                        valid_out
);

    // TODO: 2行分のラインバッファとウィンドウレジスタ

    // TODO: 入力ストリームから3x3ウィンドウを構成

    // TODO: カーネル係数との畳み込み演算

    // TODO: スケーリング・飽和処理して出力

    // TODO: ウォームアップ期間を考慮したvalid信号生成

endmodule
