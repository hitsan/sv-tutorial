// Greg Stitt
// University of Florida

`timescale 1ns / 100ps

module multiplier #(
  parameter int INPUT_WIDTH = 8,
  parameter bit IS_SIGNED = 1'b0,
  localparam int OUTPUT_WIDTH = INPUT_WIDTH * 2
) (
  input logic [INPUT_WIDTH-1:0] in0,
  input logic [INPUT_WIDTH-1:0] in1,
  output logic signed [OUTPUT_WIDTH-1:0] product
);

  generate
    if (IS_SIGNED) begin : signed_mult
      always_comb product = signed'(in0) * signed'(in1);
    end else begin : unsigned_mult
      always_comb product = in0 * in1;
    end
  endgenerate
endmodule
