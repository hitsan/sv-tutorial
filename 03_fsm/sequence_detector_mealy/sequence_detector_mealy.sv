// Mealy sequence detector "1011"

`timescale 1ns / 100ps

module sequence_detector_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic detected
);
  typedef enum logic [2:0] {
    IDLE = 3'b000,
    S1   = 3'b001,
    S10  = 3'b010,
    S101 = 3'b101
  } pattern_t;
  pattern_t state_c;
  pattern_t state_n;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_c <= IDLE;
    else state_c <= state_n;
  end

  always_comb begin
    state_n = state_c;
    case (state_c)
      IDLE: if (data_in) state_n = S1;
      S1: if (!data_in) state_n = S10;
      S10: begin
        if (data_in) state_n = S101;
        else state_n = IDLE;
      end
      S101: begin
        if (data_in) state_n = S1;
        else state_n = S10;
      end
      default: state_n = IDLE;
    endcase
  end

  assign detected = (state_c == S101) & data_in;

endmodule : sequence_detector_mealy
