// Testbench for moore_fsm_2process

`timescale 1ns / 100ps

module moore_fsm_2process_tb;
  parameter int CLK_PERIOD = 10;

  logic clk;
  logic rst_n;
  logic data_in;
  logic detected;

  int errors = 0;

  moore_fsm_2process dut (
      .clk(clk),
      .rst_n(rst_n),
      .data_in(data_in),
      .detected(detected)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 0;
    data_in = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;

    // Apply sequence 110, expect detected while in DETECTED state.
    @(negedge clk); data_in = 1;
    @(negedge clk); data_in = 1;
    @(negedge clk); data_in = 0;
    @(posedge clk);
    #1;
    if (detected !== 1'b1) begin
      $error("FAIL: expected detected=1 after 110");
      errors++;
    end

    @(posedge clk);
    #1;
    if (detected !== 1'b0) begin
      $error("FAIL: expected detected to clear");
      errors++;
    end

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("TESTS FAILED: %0d", errors);
    $finish;
  end
endmodule
