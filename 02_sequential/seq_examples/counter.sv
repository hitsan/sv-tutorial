// Exercise 4: Up counter with wrap

`timescale 1ns / 100ps

module exercise4_counter #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= '0;
    else if (count == '1) count <= '0;
    else count <= count + 1;
  end
endmodule : exercise4_counter
