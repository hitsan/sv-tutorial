// Testbench for exercise4_counter

`timescale 1ns / 100ps

module exercise4_counter_tb;
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic [WIDTH-1:0] count;

  int errors = 0;

  exercise4_counter #(
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .count(count)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;

    for (int i = 0; i < 5; i++) begin
      @(posedge clk);
      #1;
      if (count !== WIDTH'(i + 1)) begin
        $error("FAIL: count=%0d expected %0d", count, i + 1);
        errors++;
      end
    end

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("TESTS FAILED: %0d", errors);
    $finish;
  end
endmodule
