// Testbench for traffic_light_moore

`timescale 1ns / 100ps

module traffic_light_moore_tb;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic sensor;
  logic red;
  logic yellow;
  logic green;

  int errors = 0;

  traffic_light_moore dut (
      .clk(clk),
      .rst_n(rst_n),
      .sensor(sensor),
      .red(red),
      .yellow(yellow),
      .green(green)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 0;
    sensor = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;

    // After reset, should be RED.
    @(posedge clk);
    #1;
    if ({red, yellow, green} !== 3'b100) begin
      $error("FAIL: expected RED after reset");
      errors++;
    end

    // Trigger transition with sensor and allow a few cycles.
    sensor = 1;
    @(posedge clk);
    sensor = 0;
    for (int i = 0; i < 6; i++) begin
      @(posedge clk);
      if ({red, yellow, green} !== 3'b100) break;
    end
    #1;
    if ({red, yellow, green} === 3'b100) begin
      $error("FAIL: expected transition from RED after sensor");
      errors++;
    end

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("TESTS FAILED: %0d", errors);
    $finish;
  end
endmodule
