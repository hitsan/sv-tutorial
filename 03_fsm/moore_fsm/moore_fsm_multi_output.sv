// Moore FSM: multi-output example

`timescale 1ns / 100ps

module moore_fsm_multi_output (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       done,
    output logic       busy,
    output logic       valid,
    output logic [1:0] status
);
  typedef enum logic [2:0] {
    IDLE,
    INIT,
    PROCESS,
    WAIT_DONE,
    FINISH
  } state_t;

  state_t current_state, next_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else current_state <= next_state;
  end

  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (start) next_state = INIT;
      end

      INIT: begin
        next_state = PROCESS;
      end

      PROCESS: begin
        next_state = WAIT_DONE;
      end

      WAIT_DONE: begin
        if (done) next_state = FINISH;
      end

      FINISH: begin
        next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  always_comb begin
    busy   = 1'b0;
    valid  = 1'b0;
    status = 2'b00;

    case (current_state)
      IDLE: begin
        status = 2'b00;
      end

      INIT: begin
        busy   = 1'b1;
        status = 2'b01;
      end

      PROCESS: begin
        busy   = 1'b1;
        status = 2'b10;
      end

      WAIT_DONE: begin
        busy   = 1'b1;
        status = 2'b10;
      end

      FINISH: begin
        valid  = 1'b1;
        status = 2'b11;
      end
      default: begin
        busy   = 1'b0;
        valid  = 1'b0;
        status = 2'b00;
      end
    endcase
  end
endmodule : moore_fsm_multi_output
