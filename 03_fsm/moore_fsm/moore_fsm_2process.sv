// Moore FSM: 2-process example

`timescale 1ns / 100ps

module moore_fsm_2process (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic detected
);
  typedef enum logic [2:0] {
    IDLE,
    S1,
    S11,
    DETECTED
  } state_t;

  state_t current_state, next_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (data_in) next_state = S1;
      end

      S1: begin
        if (data_in) next_state = S11;
        else next_state = IDLE;
      end

      S11: begin
        if (!data_in) next_state = DETECTED;
      end

      DETECTED: begin
        if (data_in) next_state = S1;
        else next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  always_comb begin
    case (current_state)
      DETECTED: detected = 1'b1;
      default:  detected = 1'b0;
    endcase
  end
endmodule : moore_fsm_2process
