// Pipelined multiplier (Array) - testbench

`timescale 1ns / 100ps

module multiplier_pipelined_array_tb;

  // Test parameters
  parameter int INPUT_WIDTH = 8;
  parameter int OUTPUT_WIDTH = INPUT_WIDTH * 2;
  parameter int CLK_PERIOD = 10;

  // Array latency (INPUT_WIDTH stages + output register)
  localparam int LATENCY = INPUT_WIDTH + 1;

  // Signals
  logic                    clk;
  logic                    rst_n;
  logic [ INPUT_WIDTH-1:0] in0;
  logic [ INPUT_WIDTH-1:0] in1;
  logic [OUTPUT_WIDTH-1:0] product;

  // Error counter
  int                      errors = 0;

  // DUT
  multiplier_pipelined_array #(
      .INPUT_WIDTH(INPUT_WIDTH)
  ) dut (
      .clk    (clk),
      .rst_n  (rst_n),
      .in0    (in0),
      .in1    (in1),
      .product(product)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // Test sequence
  initial begin
    $display("=================================================");
    $display("Pipelined Multiplier Test (Array)");
    $display("=================================================\n");

    // Init
    rst_n = 0;
    in0   = 0;
    in1   = 0;

    // Release reset
    #(CLK_PERIOD * 2);
    rst_n = 1;
    #(CLK_PERIOD);

    // Basic tests
    $display("\n[Test 1] Basic tests");
    test_case(8'd5, 8'd3, "5 x 3");
    test_case(8'd0, 8'd100, "0 x 100");
    test_case(8'd42, 8'd1, "42 x 1");
    test_case(8'd1, 8'd255, "1 x 255");

    // Boundary tests
    $display("\n[Test 2] Boundary tests");
    test_case(8'd255, 8'd255, "255 x 255");
    test_case(8'd2, 8'd2, "2 x 2");
    test_case(8'd4, 8'd4, "4 x 4");
    test_case(8'd8, 8'd8, "8 x 8");
    test_case(8'd16, 8'd16, "16 x 16");

    // Pattern tests
    $display("\n[Test 3] Pattern tests");
    test_case(8'h55, 8'hAA, "0x55 x 0xAA");
    test_case(8'hFF, 8'h01, "0xFF x 0x01");
    test_case(8'h0F, 8'hF0, "0x0F x 0xF0");

    // Random tests
    $display("\n[Test 4] Random tests");
    for (int i = 0; i < 30; i++) begin
      automatic logic [INPUT_WIDTH-1:0] a = INPUT_WIDTH'($urandom);
      automatic logic [INPUT_WIDTH-1:0] b = INPUT_WIDTH'($urandom);
      test_case(a, b, $sformatf("Random %0d: %0d x %0d", i, a, b));
    end

    // Summary
    $display("\n=================================================");
    $display("Test Summary");
    $display("=================================================");
    $display("Errors: %0d", errors);
    $display("-------------------------------------------------");
    if (errors == 0) begin
      $display("ALL TESTS PASSED!");
    end else begin
      $display("TESTS FAILED!");
    end
    $display("=================================================\n");

    $finish;
  end

  // Timeout guard
  initial begin
    #100000;
    $display("TIMEOUT!");
    $finish;
  end

  // test_case task
  task test_case(input logic [INPUT_WIDTH-1:0] a, input logic [INPUT_WIDTH-1:0] b,
                 input string description);
    logic [OUTPUT_WIDTH-1:0] expected;

    // Expected result
    expected = a * b;

    // Drive inputs
    in0 = a;
    in1 = b;

    // Wait for latency
    #(CLK_PERIOD * LATENCY);

    // Check
    if (product !== expected) begin
      $error("[%0t] FAILED: %s = %0d (expected %0d)", $time, description, product, expected);
      errors++;
    end else begin
      $display("[%0t] PASSED: %s = %0d", $time, description, product);
    end

    // Wait one cycle
    #(CLK_PERIOD);
  endtask

endmodule
