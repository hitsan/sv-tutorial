// Moore edge detector

`timescale 1ns / 100ps

module edge_detector_moore (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic edge_detected
);
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    DETECTED = 2'b01,
    HIGH = 2'b10
  } state_t;

  state_t current_state;
  state_t next_state;
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
      IDLE: if (data_in) next_state = DETECTED;
      DETECTED: begin
        if (data_in) next_state = HIGH;
        else next_state = IDLE;
      end
      HIGH: if (!data_in) next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end
  assign edge_detected = (current_state == DETECTED);

endmodule : edge_detector_moore
