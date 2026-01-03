// Handshake controller (hybrid output)

`timescale 1ns / 100ps

module handshake_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic ready,
    output logic valid,
    output logic ack
);
  typedef enum logic [1:0] {
    IDLE,
    ACTIVE,
    DONE
  } state_t;
  state_t state_c;
  state_t state_n;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_c <= IDLE;
    else state_c <= state_n;
  end

  always_comb begin
    state_n = state_c;
    case (state_c)
      IDLE: if (start) state_n = ACTIVE;
      ACTIVE: if (ready) state_n = DONE;
      DONE: state_n = IDLE;
      default: state_n = IDLE;
    endcase
  end

  always_comb begin
    ack = 1'b0;
    case (state_c)
      ACTIVE:  if (ready) ack = 1'b1;
      default: ack = 1'b0;
    endcase
  end

  assign valid = (state_c == ACTIVE);
endmodule : handshake_controller
