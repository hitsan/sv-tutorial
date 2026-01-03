// パイプライン化された乗算器
// 組み合わせ回路版 (../combinational/exercises/multiplier.sv) を参考に実装してください

`timescale 1ns / 100ps

module multiplier_pipelined #(
    parameter int INPUT_WIDTH = 8,
    parameter bit IS_SIGNED = 1'b0,
    localparam int OUTPUT_WIDTH = INPUT_WIDTH * 2
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic [INPUT_WIDTH-1:0]   in0,
    input  logic [INPUT_WIDTH-1:0]   in1,
    output logic [OUTPUT_WIDTH-1:0]  product
);

  // TODO: 2ステージパイプラインを実装
  // Stage 1: 入力レジスタ
  // Stage 2: 乗算 + 出力レジスタ
  logic [INPUT_WIDTH-1:0] in0_r = 0;
  logic [INPUT_WIDTH-1:0] in1_r = 0;
  generate
    if (IS_SIGNED) begin : signed_mult
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          product <= '0;
          in0_r <= '0;
          in1_r <= '0;
        end
        else begin
          in0_r <= signed'(in0);
          in1_r <= signed'(in1);
          product <= in0_r * in1_r;
        end
      end
    end else begin : unsigned_mult
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          product <= '0;
          in0_r <= '0;
          in1_r <= '0;
        end
        else begin
          in0_r <= in0;
          in1_r <= in1;
          product <= in0_r * in1_r;
        end
      end
    end
  endgenerate

endmodule : multiplier_pipelined
