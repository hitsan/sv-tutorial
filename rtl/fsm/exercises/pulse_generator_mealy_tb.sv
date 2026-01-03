// pulse_generator_mealy テストベンチ

module pulse_generator_mealy_tb;
  logic clk;
  logic rst_n;
  logic start;
  logic pulse;

  // DUT instantiation
  pulse_generator_mealy dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .pulse(pulse)
  );

  // Clock generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    $display("=== pulse_generator_mealy Test Start ===");

    // Reset
    rst_n = 0;
    start = 0;
    #20;
    rst_n = 1;
    #10;

    // Test 1: 4クロック幅のパルス生成
    $display("\nTest 1: Generate 4-clock pulse");
    start = 1;
    #10;
    start = 0;

    // Mealy型なので、start入力と同じサイクルからpulse=1
    if (pulse) $display("  Cycle 1: PASS - pulse=1");
    else $display("  Cycle 1: FAIL - pulse should be 1");

    #10;
    if (pulse) $display("  Cycle 2: PASS - pulse=1");
    else $display("  Cycle 2: FAIL - pulse should be 1");

    #10;
    if (pulse) $display("  Cycle 3: PASS - pulse=1");
    else $display("  Cycle 3: FAIL - pulse should be 1");

    #10;
    if (pulse) $display("  Cycle 4: PASS - pulse=1");
    else $display("  Cycle 4: FAIL - pulse should be 1");

    #10;
    if (!pulse) $display("  Cycle 5: PASS - pulse=0 (pulse ended)");
    else $display("  Cycle 5: FAIL - pulse should be 0");

    // Test 2: 2回目のパルス生成
    $display("\nTest 2: Generate second pulse");
    #10;
    start = 1;
    #10;
    start = 0;

    if (pulse) $display("  Second pulse started: PASS");
    else $display("  Second pulse started: FAIL");

    // 4クロック待つ
    #30;
    if (pulse) $display("  During pulse: PASS");
    else $display("  During pulse: FAIL");

    #10;
    if (!pulse) $display("  Second pulse ended: PASS");
    else $display("  Second pulse ended: FAIL");

    #20;
    $display("\n=== pulse_generator_mealy Test Complete ===");
    $finish;
  end

  // Waveform dump
  initial begin
    $dumpfile("pulse_generator_mealy.vcd");
    $dumpvars(0, pulse_generator_mealy_tb);
  end

endmodule
