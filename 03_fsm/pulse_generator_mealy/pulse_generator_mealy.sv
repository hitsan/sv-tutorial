// Mealy pulse generator

`timescale 1ns / 100ps

module pulse_generator_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic pulse
);
  typedef enum logic {
    IDLE,
    PULSE
  } state_t;

  state_t state_c;
  state_t state_n;
  logic [2:0] count;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_c <= IDLE;
    else state_c <= state_n;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= 0;
    else if (state_c == PULSE) count <= count + 1;
    else count <= 0;
  end

  always_comb begin
    state_n = state_c;
    case (state_c)
      IDLE: if (start) state_n = PULSE;
      PULSE: begin
        if (count > 4) begin
          state_n = IDLE;
        end
      end
    endcase
  end

  always_comb begin
    pulse = 1'b0;
    case (state_c)
      IDLE: begin
        if (start) pulse = 1'b1;
      end
      PULSE: begin
        if (count < 4) pulse = 1'b1;
      end
    endcase
  end

endmodule : pulse_generator_mealy
