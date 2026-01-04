//============================================================================
// File: fir_filter_direct.sv
// Description: 4タップFIRフィルタ - 直接形I構造 (Direct Form I)
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

module fir_filter_direct #(
    parameter int DATA_WIDTH = 16,      // 入力データのビット幅
    parameter int COEFF_WIDTH = 16,     // 係数のビット幅
    parameter int NUM_TAPS = 4,         // タップ数（固定）
    // フィルタ係数（Q1.15形式の例：0.25, 0.5, 0.5, 0.25）
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

    // TODO: 内部信号定義
    // - シフトレジスタ（遅延線）: logic signed [DATA_WIDTH-1:0] shift_reg [0:NUM_TAPS-1]
    // - 乗算結果: logic signed [DATA_WIDTH+COEFF_WIDTH-1:0] products [0:NUM_TAPS-1]
    // - 累算結果: logic signed [ACC_WIDTH-1:0] sum (ACC_WIDTH = DATA_WIDTH + COEFF_WIDTH + 2)
    // - 係数配列: logic signed [COEFF_WIDTH-1:0] coeffs [0:NUM_TAPS-1]

    //========================================================================
    // TODO: シフトレジスタ（遅延線）
    // 最新のサンプルをshift_reg[0]に格納し、古いサンプルを順次シフト
    //========================================================================

    //========================================================================
    // TODO: MAC演算（Multiply-Accumulate）
    // 各タップの係数とサンプルを乗算し、すべてを加算
    //========================================================================

    //========================================================================
    // TODO: 出力（スケーリング）
    // Q1.15 * Q1.15 = Q2.30 なので、15ビット右シフトでQ1.15に戻す
    //========================================================================

    //========================================================================
    // TODO: valid信号の遅延（1サイクルのレイテンシ）
    //========================================================================

endmodule
