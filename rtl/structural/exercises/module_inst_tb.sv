// module_inst テストベンチ

module module_inst_tb;
  logic [3:0] in;
  logic [1:0] sel;
  logic       out;

  // DUT instantiation
  mux4x1_structural dut (
    .in(in),
    .sel(sel),
    .out(out)
  );

  // Test stimulus
  initial begin
    $display("=== mux4x1_structural Test Start ===");

    // Test all combinations
    for (int s = 0; s < 4; s++) begin
      for (int i = 0; i < 16; i++) begin
        in = i;
        sel = s;
        #1;

        // Expected output is in[sel]
        if (out == in[sel]) begin
          if (i == 0) $display("  sel=%0d: PASS", sel);
        end else begin
          $display("  FAIL: in=4'b%04b, sel=%0d, out=%b, expected=%b",
                   in, sel, out, in[sel]);
        end
      end
    end

    $display("=== mux4x1_structural Test Complete ===");
    $finish;
  end

endmodule
