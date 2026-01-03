// Testbench for exercise5_updown_counter

`timescale 1ns / 100ps

module exercise5_updown_counter_tb;
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic en;
  logic up;
  logic [WIDTH-1:0] count;

  int errors = 0;

  exercise5_updown_counter #(
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .en(en),
      .up(up),
      .count(count)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 0;
    en = 0;
    up = 1;
    #(CLK_PERIOD * 2);
    rst_n = 1;

    en = 1;
    up = 1;
    repeat (3) @(posedge clk);
    #1;
    if (count !== 3) begin
      $error("FAIL: count=%0d expected 3 after up", count);
      errors++;
    end

    up = 0;
    repeat (2) @(posedge clk);
    #1;
    if (count !== 1) begin
      $error("FAIL: count=%0d expected 1 after down", count);
      errors++;
    end

    en = 0;
    @(posedge clk);
    #1;
    if (count !== 1) begin
      $error("FAIL: count changed when en=0");
      errors++;
    end

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("TESTS FAILED: %0d", errors);
    $finish;
  end
endmodule
