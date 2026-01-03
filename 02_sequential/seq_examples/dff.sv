// Exercise 1: D flip-flop with async reset

`timescale 1ns / 100ps

module exercise1_dff #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= '0;
    else q <= d;
  end
endmodule : exercise1_dff
