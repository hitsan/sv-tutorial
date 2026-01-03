// Pipelined multiplier: Array multiplier pipeline
// - Each row is one pipeline stage

`timescale 1ns / 100ps

module multiplier_pipelined_array #(
    parameter  int INPUT_WIDTH  = 8,
    localparam int OUTPUT_WIDTH = INPUT_WIDTH * 2
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [ INPUT_WIDTH-1:0] in0,
    input  logic [ INPUT_WIDTH-1:0] in1,
    output logic [OUTPUT_WIDTH-1:0] product
);
  logic [OUTPUT_WIDTH-1:0] sum[INPUT_WIDTH];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < INPUT_WIDTH; i++) begin
        sum[i] <= '0;
      end
      product <= '0;
    end else begin
      sum[0] <= OUTPUT_WIDTH'(in0) & {OUTPUT_WIDTH{in1[0]}};
      for (int i = 1; i < INPUT_WIDTH; i++) begin
        sum[i] <= sum[i-1] + ((OUTPUT_WIDTH'(in0) & {OUTPUT_WIDTH{in1[i]}}) << i);
      end
      product <= sum[INPUT_WIDTH-1];
    end
  end
endmodule : multiplier_pipelined_array
