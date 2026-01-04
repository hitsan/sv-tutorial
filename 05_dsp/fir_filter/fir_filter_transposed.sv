//============================================================================
// File: fir_filter_transposed.sv
// Description: 4タップFIRフィルタ - 転置形II構造 (Transposed Form II)
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

module fir_filter_transposed #(
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
    // - 係数配列: logic signed [COEFF_WIDTH-1:0] coeffs [0:NUM_TAPS-1]
    // - 乗算結果: logic signed [DATA_WIDTH+COEFF_WIDTH-1:0] products [0:NUM_TAPS-1]
    // - 加算結果を保持するレジスタチェーン: logic signed [ACC_WIDTH-1:0] acc_regs [0:NUM_TAPS-2]

    //========================================================================
    // TODO: 乗算
    //========================================================================

    //========================================================================
    // TODO: 転置形の加算器チェーン
    // Stage 0: product[0] + acc_regs[0]
    // Stage 1: product[1] + acc_regs[0] → acc_regs[1]
    // Stage 2: product[2] + acc_regs[1] → acc_regs[2]
    // Stage 3: product[3] + acc_regs[2] → output
    //========================================================================

    //========================================================================
    // TODO: 出力とスケーリング
    //========================================================================

    //========================================================================
    // TODO: valid信号の遅延
    //========================================================================

endmodule
