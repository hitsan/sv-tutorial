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

    // TODO: 内部信号定義
    // - ラインバッファ（2行分のシフトレジスタ）
    //   logic [PIXEL_WIDTH-1:0] line_buffer_0 [0:IMAGE_WIDTH-1]
    //   logic [PIXEL_WIDTH-1:0] line_buffer_1 [0:IMAGE_WIDTH-1]
    //
    // - 3x3ウィンドウレジスタ
    //   logic [PIXEL_WIDTH-1:0] window [0:2][0:2]  // window[row][col]
    //
    // - ピクセルカウンタ（ウォームアップ期間の管理）
    //   logic [15:0] pixel_count
    //
    // - カーネル係数配列
    //   logic signed [COEFF_WIDTH-1:0] kernel [0:2][0:2]

    //========================================================================
    // TODO: ラインバッファとウィンドウのシフト処理
    // ラインバッファをシフトし、3x3ウィンドウを構成する
    //========================================================================

    //========================================================================
    // TODO: 畳み込み演算（MAC）
    // 9個の乗算と加算を実行
    //========================================================================

    //========================================================================
    // TODO: 出力（スケーリング + 飽和処理）
    // SCALE_SHIFTビット右シフトし、0〜255の範囲に飽和
    //========================================================================

    //========================================================================
    // TODO: valid信号（ウォームアップ期間後に有効）
    // 最初の2行 + 2ピクセルは無効データ
    //========================================================================

endmodule
