//============================================================================
// File: fir_filter_pipelined.sv
// Description: 4タップFIRフィルタ - パイプライン化実装
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

module fir_filter_pipelined #(
    parameter int DATA_WIDTH = 16,
    parameter int COEFF_WIDTH = 16,
    parameter int NUM_TAPS = 4,
    // フィルタ係数（Q1.15形式）
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_0 = 16'sh2000,  // 0.25
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_1 = 16'sh4000,  // 0.5
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_2 = 16'sh4000,  // 0.5
    parameter logic signed [COEFF_WIDTH-1:0] COEFF_3 = 16'sh2000   // 0.25
) (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic signed [DATA_WIDTH-1:0]  data_in,
    input  logic                          valid_in,
    output logic signed [DATA_WIDTH-1:0]  data_out,
    output logic                          valid_out
);

    // パイプライン構造:
    // Stage 0: シフトレジスタ + 乗算
    // Stage 1: 加算
    //
    // レイテンシ: 2サイクル
    // スループット: 1サンプル/サイクル
    // クリティカルパス: 乗算 または 加算（分割される）

    // TODO: 内部信号定義
    // - 係数配列: logic signed [COEFF_WIDTH-1:0] coeffs [0:NUM_TAPS-1]
    // - シフトレジスタ: logic signed [DATA_WIDTH-1:0] shift_reg [0:NUM_TAPS-1]
    // - 乗算結果: logic signed [DATA_WIDTH+COEFF_WIDTH-1:0] products [0:NUM_TAPS-1]
    // - パイプラインレジスタ（Stage 1用）: logic signed [DATA_WIDTH+COEFF_WIDTH-1:0] products_reg [0:NUM_TAPS-1]
    // - 累算結果: logic signed [ACC_WIDTH-1:0] sum, sum_reg
    // - valid信号のパイプライン: logic valid_stage1, valid_stage2

    //========================================================================
    // TODO: Stage 0 - シフトレジスタ
    //========================================================================

    //========================================================================
    // TODO: Stage 0 - 乗算（組み合わせ回路）
    //========================================================================

    //========================================================================
    // TODO: パイプラインレジスタ（乗算結果を保持）
    //========================================================================

    //========================================================================
    // TODO: Stage 1 - 加算
    //========================================================================

    //========================================================================
    // TODO: 出力（スケーリング）
    //========================================================================

endmodule
