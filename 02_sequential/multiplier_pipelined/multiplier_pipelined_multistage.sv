// Pipelined multiplier: Multi-stage pipeline (3 stages)
// - Input register, multiply register, output register

`timescale 1ns / 100ps

module multiplier_pipelined_multistage #(
    parameter  int INPUT_WIDTH  = 8,
    localparam int OUTPUT_WIDTH = INPUT_WIDTH * 2
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [ INPUT_WIDTH-1:0] in0,
    input  logic [ INPUT_WIDTH-1:0] in1,
    output logic [OUTPUT_WIDTH-1:0] product
);
  logic [ INPUT_WIDTH-1:0] in0_r;
  logic [ INPUT_WIDTH-1:0] in1_r;
  logic [OUTPUT_WIDTH-1:0] mul_r;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      in0_r   <= '0;
      in1_r   <= '0;
      product <= '0;
    end else begin
      in0_r   <= in0;
      in1_r   <= in1;
      mul_r   <= in0_r * in1_r;
      product <= mul_r;
    end
  end
endmodule : multiplier_pipelined_multistage
