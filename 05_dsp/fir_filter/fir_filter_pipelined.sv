//============================================================
// File: fir_filter_pipelined.sv
// Description: 4タップFIRフィルタ - パイプライン化実装
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================

`timescale 1ns / 1ps

module fir_filter_pipelined #(
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

  // パイプライン構造:
  // Stage 0: シフトレジスタ + 乗算
  // Stage 1: 加算
  //
  // レイテンシ: 2サイクル
  // スループット: 1サンプル/サイクル
  // クリティカルパス: 乗算 または 加算（分割される）

  // TODO: 内部信号定義
  localparam int MUL_WIDTH = DATA_WIDTH * 2;
  logic [DATA_WIDTH-1:0] in_reg[NUM_TAPS-1:0];
  logic [MUL_WIDTH-1:0] mul_reg[NUM_TAPS-1:0];
  logic [MUL_WIDTH-1:0] mul_pipe[NUM_TAPS-1:0];
  logic [MUL_WIDTH-1:0] accum;
  logic [1:0] valid_stage;

  // TODO: Stage 0 - シフトレジスタ
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < NUM_TAPS; i++) begin
        in_reg[i] <= '0;
      end
    end else begin
      in_reg[0] <= data_in;
      for (int i = 1; i < NUM_TAPS; i++) begin
        in_reg[i] <= in_reg[i-1];
      end
    end
  end

  // TODO: Stage 0 - 乗算
  always_comb begin
    mul_reg[0] = in_reg[0] * COEFF_0;
    mul_reg[1] = in_reg[1] * COEFF_1;
    mul_reg[2] = in_reg[2] * COEFF_2;
    mul_reg[3] = in_reg[3] * COEFF_3;
  end

  // TODO: パイプラインレジスタ（乗算結果を保持）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < NUM_TAPS; i++) begin
        mul_pipe[i] <= '0;
      end
    end else begin
      for (int i = 0; i < NUM_TAPS; i++) begin
        mul_pipe[i] <= mul_reg[i];
      end
    end
  end


  // TODO: Stage 1 - 加算
  assign accum = mul_pipe[0] + mul_pipe[1] + mul_pipe[2] + mul_pipe[3];

  // TODO: 出力（スケーリング）
  assign data_out = 16'(accum >> 15);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) valid_stage <= 2'b00;
    else valid_stage <= {valid_stage[0], valid_in};
  end
  assign valid_out = valid_stage[1];

endmodule
