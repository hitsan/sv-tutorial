// Moore FSM: traffic light controller

`timescale 1ns / 100ps

module traffic_light_moore (
    input  logic clk,
    input  logic rst_n,
    input  logic sensor,
    output logic red,
    output logic yellow,
    output logic green
);
  typedef enum logic [1:0] {
    RED,
    RED_YELLOW,
    GREEN,
    YELLOW
  } state_t;

  state_t current_state, next_state;
  logic [3:0] timer;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= RED;
    else current_state <= next_state;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      timer <= '0;
    end else begin
      if (current_state != next_state) timer <= '0;
      else timer <= timer + 1;
    end
  end

  always_comb begin
    next_state = current_state;

    case (current_state)
      RED: begin
        if (timer >= 4'd5 || sensor) next_state = RED_YELLOW;
      end

      RED_YELLOW: begin
        if (timer >= 4'd2) next_state = GREEN;
      end

      GREEN: begin
        if (timer >= 4'd10) next_state = YELLOW;
      end

      YELLOW: begin
        if (timer >= 4'd3) next_state = RED;
      end
    endcase
  end

  always_comb begin
    {red, yellow, green} = 3'b000;

    case (current_state)
      RED:        {red, yellow, green} = 3'b100;
      RED_YELLOW: {red, yellow, green} = 3'b110;
      GREEN:      {red, yellow, green} = 3'b001;
      YELLOW:     {red, yellow, green} = 3'b010;
    endcase
  end
endmodule : traffic_light_moore
