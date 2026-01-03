// Exercise 5: Up/down counter with enable

`timescale 1ns / 100ps

module exercise5_updown_counter #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             up,
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= '0;
    else if (en) begin
      if (up) count <= count + 1;
      else count <= count - 1;
    end
  end
endmodule : exercise5_updown_counter
