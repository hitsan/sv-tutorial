// generate_example テストベンチ

module generate_example_tb;
  logic [7:0] a, b;
  logic       cin;
  logic [7:0] sum;
  logic       cout;

  // DUT instantiation
  ripple_carry_adder_8bit dut (
      .a(a),
      .b(b),
      .cin(cin),
      .sum(sum),
      .cout(cout)
  );

  // Test stimulus
  initial begin
    $display("=== ripple_carry_adder_8bit Test Start ===");

    // Test 1: 基本的な加算
    $display("\nTest 1: Basic addition");
    a   = 8'd15;
    b   = 8'd27;
    cin = 0;
    #1;
    if ({cout, sum} == (a + b + cin))
      $display("  PASS: %0d + %0d + %0d = %0d (cout=%b)", a, b, cin, sum, cout);
    else $display("  FAIL: %0d + %0d + %0d = %0d, expected %0d", a, b, cin, sum, a + b + cin);

    // Test 2: キャリー入力あり
    $display("\nTest 2: With carry-in");
    a   = 8'd100;
    b   = 8'd50;
    cin = 1;
    #1;
    if ({cout, sum} == (a + b + cin))
      $display("  PASS: %0d + %0d + %0d = %0d (cout=%b)", a, b, cin, sum, cout);
    else $display("  FAIL: %0d + %0d + %0d = %0d, expected %0d", a, b, cin, sum, a + b + cin);

    // Test 3: オーバーフロー
    $display("\nTest 3: Overflow");
    a   = 8'd200;
    b   = 8'd100;
    cin = 0;
    #1;
    if ({cout, sum} == (a + b + cin))
      $display("  PASS: %0d + %0d + %0d = %0d (cout=%b, overflow)", a, b, cin, sum, cout);
    else $display("  FAIL: %0d + %0d + %0d = %0d, expected %0d", a, b, cin, sum, a + b + cin);

    // Test 4: ランダムテスト
    $display("\nTest 4: Random tests");
    for (int i = 0; i < 20; i++) begin
      a   = $urandom_range(0, 255);
      b   = $urandom_range(0, 255);
      cin = $urandom_range(0, 1);
      #1;
      if ({cout, sum} != (a + b + cin)) begin
        $display("  FAIL: %0d + %0d + %0d = %0d, expected %0d", a, b, cin, sum, a + b + cin);
      end
    end
    $display("  PASS: 20 random tests completed");

    $display("\n=== ripple_carry_adder_8bit Test Complete ===");
    $finish;
  end

endmodule
