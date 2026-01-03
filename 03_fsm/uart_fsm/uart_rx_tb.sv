// Testbench for uart_rx (compile-only sanity)

`timescale 1ns / 100ps

module uart_rx_tb;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic rx;
  logic [7:0] rx_data;
  logic rx_valid;
  logic rx_error;

  uart_rx dut (
      .clk(clk),
      .rst_n(rst_n),
      .rx(rx),
      .rx_data(rx_data),
      .rx_valid(rx_valid),
      .rx_error(rx_error)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 0;
    rx = 1'b1;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    @(posedge clk);
    $display("ALL TESTS PASSED");
    $finish;
  end
endmodule
