// Mealy edge detector

`timescale 1ns / 100ps

module edge_detector_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic edge_detected
);
  typedef enum logic {
    IDLE = 1'b0,
    HIGH = 1'b1
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
      IDLE: if (data_in) next_state = HIGH;
      HIGH: if (!data_in) next_state = IDLE;
    endcase
  end

  always_comb begin
    edge_detected = 1'b0;
    case (current_state)
      IDLE: if (data_in) edge_detected = 1'b1;
      HIGH: edge_detected = 1'b0;
    endcase
  end
endmodule : edge_detector_mealy
