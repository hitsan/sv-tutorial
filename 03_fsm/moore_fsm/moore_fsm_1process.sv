// Moore FSM: 1-process example

`timescale 1ns / 100ps

module moore_fsm_1process (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic detected
);
  typedef enum logic [2:0] {
    IDLE     = 3'b000,
    S1       = 3'b001,
    S11      = 3'b010,
    DETECTED = 3'b011
  } state_t;

  state_t state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      detected <= 1'b0;
    end else begin
      detected <= 1'b0;

      case (state)
        IDLE: begin
          if (data_in) state <= S1;
          else state <= IDLE;
        end

        S1: begin
          if (data_in) state <= S11;
          else state <= IDLE;
        end

        S11: begin
          if (!data_in) begin
            state <= DETECTED;
          end else begin
            state <= S11;
          end
        end

        DETECTED: begin
          detected <= 1'b1;
          if (data_in) state <= S1;
          else state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end
endmodule : moore_fsm_1process
