// Testbench for exercise3_pipeline

`timescale 1ns / 100ps

module exercise3_pipeline_tb;
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic [WIDTH-1:0] d;
  logic [WIDTH-1:0] q;

  int errors = 0;

  exercise3_pipeline #(
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

    d = 8'hFF;
    @(posedge clk);
    #1;
    if (q !== 8'h00) begin
      $error("FAIL: q=0x%h expected 0x00 after 1 cycle", q);
      errors++;
    end

    @(posedge clk);
    #1;
    if (q !== 8'hFF) begin
      $error("FAIL: q=0x%h expected 0xFF after 2 cycles", q);
      errors++;
    end

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("TESTS FAILED: %0d", errors);
    $finish;
  end
endmodule
