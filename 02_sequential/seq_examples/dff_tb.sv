// Testbench for exercise1_dff

`timescale 1ns / 100ps

module exercise1_dff_tb;
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic [WIDTH-1:0] d;
  logic [WIDTH-1:0] q;

  int errors = 0;

  exercise1_dff #(
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .d(d),
      .q(q)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 0;
    d = '0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    @(posedge clk);

    d = 8'hAA;
    @(posedge clk);
    #1;
    if (q !== 8'hAA) begin
      $error("FAIL: q=0x%h expected 0xAA", q);
      errors++;
    end

    d = 8'h55;
    @(posedge clk);
    #1;
    if (q !== 8'h55) begin
      $error("FAIL: q=0x%h expected 0x55", q);
      errors++;
    end

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("TESTS FAILED: %0d", errors);
    $finish;
  end
endmodule
