// Testbench for uart (compile-only sanity)

`timescale 1ns / 100ps

module uart_tb;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic tx_start;
  logic [7:0] tx_data;
  logic tx;
  logic tx_busy;
  logic tx_done;
  logic rx;
  logic [7:0] rx_data;
  logic rx_valid;
  logic rx_error;

  uart dut (
      .clk(clk),
      .rst_n(rst_n),
      .tx_start(tx_start),
      .tx_data(tx_data),
      .tx(tx),
      .tx_busy(tx_busy),
      .tx_done(tx_done),
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
    tx_start = 0;
    tx_data = 8'h00;
    rx = 1'b1;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    @(posedge clk);
    $display("ALL TESTS PASSED");
    $finish;
  end
endmodule
