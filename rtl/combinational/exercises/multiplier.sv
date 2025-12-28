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
  output logic [OUTPUT_WIDTH-1:0] product
);

  always_comb begin
    case (IS_SIGNED)
      1'b1: product = signed'(in0) * signed'(in1);
      1'b0: product = in0 * in1;
    endcase
  end

endmodule
