// Testbench for exercise2_enable_reg

`timescale 1ns / 100ps

module exercise2_enable_reg_tb;
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic en;
  logic [WIDTH-1:0] d;
  logic [WIDTH-1:0] q;

  int errors = 0;

  exercise2_enable_reg #(
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .en(en),
      .d(d),
      .q(q)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 0;
    en = 0;
    d = '0;
    #(CLK_PERIOD * 2);
    rst_n = 1;

    d = 8'h12;
    en = 1;
    @(posedge clk);
    #1;
    if (q !== 8'h12) begin
      $error("FAIL: q=0x%h expected 0x12", q);
      errors++;
    end

    d = 8'h34;
    en = 0;
    @(posedge clk);
    #1;
    if (q !== 8'h12) begin
      $error("FAIL: q=0x%h expected hold 0x12", q);
      errors++;
    end

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("TESTS FAILED: %0d", errors);
    $finish;
  end
endmodule
