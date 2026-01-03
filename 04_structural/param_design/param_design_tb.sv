// param_design テストベンチ

module param_design_tb;
  // Test parameters
  localparam int WIDTH = 8;
  localparam int N = 4;

  logic [WIDTH-1:0] in  [N-1:0];
  logic [WIDTH-1:0] sum;

  // DUT instantiation
  adder_tree #(
      .WIDTH(WIDTH),
      .N(N)
  ) dut (
      .in (in),
      .sum(sum)
  );

  // Expected sum calculation
  function automatic logic [WIDTH-1:0] calc_expected_sum();
    logic [WIDTH-1:0] temp_sum = 0;
    for (int i = 0; i < N; i++) begin
      temp_sum += in[i];
    end
    return temp_sum;
  endfunction

  // Test stimulus
  initial begin
    $display("=== adder_tree Test Start (WIDTH=%0d, N=%0d) ===", WIDTH, N);

    // Test 1: 基本的な加算
    $display("\nTest 1: Basic addition");
    in[0] = 8'd10;
    in[1] = 8'd20;
    in[2] = 8'd30;
    in[3] = 8'd40;
    #1;
    if (sum == calc_expected_sum())
      $display("  PASS: %0d + %0d + %0d + %0d = %0d", in[0], in[1], in[2], in[3], sum);
    else $display("  FAIL: sum=%0d, expected=%0d", sum, calc_expected_sum());

    // Test 2: ゼロを含む
    $display("\nTest 2: With zeros");
    in[0] = 8'd0;
    in[1] = 8'd100;
    in[2] = 8'd0;
    in[3] = 8'd55;
    #1;
    if (sum == calc_expected_sum())
      $display("  PASS: %0d + %0d + %0d + %0d = %0d", in[0], in[1], in[2], in[3], sum);
    else $display("  FAIL: sum=%0d, expected=%0d", sum, calc_expected_sum());

    // Test 3: オーバーフロー
    $display("\nTest 3: Overflow");
    in[0] = 8'd200;
    in[1] = 8'd150;
    in[2] = 8'd100;
    in[3] = 8'd50;
    #1;
    if (sum == calc_expected_sum())
      $display(
          "  PASS: %0d + %0d + %0d + %0d = %0d (overflow, wraps to 8-bit)",
          in[0],
          in[1],
          in[2],
          in[3],
          sum
      );
    else $display("  FAIL: sum=%0d, expected=%0d", sum, calc_expected_sum());

    // Test 4: 最大値
    $display("\nTest 4: Maximum values");
    in[0] = 8'd255;
    in[1] = 8'd255;
    in[2] = 8'd255;
    in[3] = 8'd255;
    #1;
    if (sum == calc_expected_sum()) $display("  PASS: 255 + 255 + 255 + 255 = %0d (wrapped)", sum);
    else $display("  FAIL: sum=%0d, expected=%0d", sum, calc_expected_sum());

    // Test 5: ランダムテスト
    $display("\nTest 5: Random tests");
    for (int test = 0; test < 20; test++) begin
      for (int i = 0; i < N; i++) begin
        in[i] = $urandom_range(0, 255);
      end
      #1;
      if (sum != calc_expected_sum()) begin
        $display("  FAIL: Test %0d failed", test);
        for (int i = 0; i < N; i++) begin
          $display("    in[%0d]=%0d", i, in[i]);
        end
        $display("    sum=%0d, expected=%0d", sum, calc_expected_sum());
      end
    end
    $display("  PASS: 20 random tests completed");

    $display("\n=== adder_tree Test Complete ===");
    $finish;
  end

endmodule

// 追加テスト: 異なるパラメータでのインスタンス化
module param_design_extended_tb;
  // Test with N=8, WIDTH=16
  localparam int WIDTH2 = 16;
  localparam int N2 = 8;

  logic [WIDTH2-1:0] in2  [N2-1:0];
  logic [WIDTH2-1:0] sum2;

  adder_tree #(
      .WIDTH(WIDTH2),
      .N(N2)
  ) dut2 (
      .in (in2),
      .sum(sum2)
  );

  // Test with N=2, WIDTH=4
  localparam int WIDTH3 = 4;
  localparam int N3 = 2;

  logic [WIDTH3-1:0] in3  [N3-1:0];
  logic [WIDTH3-1:0] sum3;

  adder_tree #(
      .WIDTH(WIDTH3),
      .N(N3)
  ) dut3 (
      .in (in3),
      .sum(sum3)
  );

  initial begin
    $display("\n=== Extended Parameter Tests ===");

    // Test N=8, WIDTH=16
    $display("\nTest: N=8, WIDTH=16");
    for (int i = 0; i < N2; i++) begin
      in2[i] = 16'd1000 + i * 100;
    end
    #1;
    $display("  Input: 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700");
    $display("  Sum: %0d (expected: %0d)", sum2, 16'd10800);

    // Test N=2, WIDTH=4
    $display("\nTest: N=2, WIDTH=4");
    in3[0] = 4'd7;
    in3[1] = 4'd9;
    #1;
    $display("  Input: %0d, %0d", in3[0], in3[1]);
    $display("  Sum: %0d (expected: 0, wraps in 4-bit)", sum3);

    $display("\n=== All Tests Complete ===");
    $finish;
  end

endmodule
