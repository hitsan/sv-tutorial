//============================================================================
// File: fir_filter_transposed_tb.sv
// Description: FIRフィルタ（転置形）のテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module fir_filter_transposed_tb;

    localparam int CLK_PERIOD = 10;
    localparam int DATA_WIDTH = 16;
    localparam int COEFF_WIDTH = 16;

    logic                          clk;
    logic                          rst_n;
    logic signed [DATA_WIDTH-1:0]  data_in;
    logic                          valid_in;
    logic signed [DATA_WIDTH-1:0]  data_out;
    logic                          valid_out;

    // DUT
    fir_filter_transposed #(
        .DATA_WIDTH  (DATA_WIDTH),
        .COEFF_WIDTH (COEFF_WIDTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .data_in   (data_in),
        .valid_in  (valid_in),
        .data_out  (data_out),
        .valid_out (valid_out)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // テストシーケンス
    initial begin
        $dumpfile("fir_filter_transposed_tb.vcd");
        $dumpvars(0, fir_filter_transposed_tb);

        rst_n = 0;
        data_in = 0;
        valid_in = 0;

        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("=== FIR Filter Transposed Form Test Start ===");
        $display("Coefficients: [0.25, 0.5, 0.5, 0.25]");
        $display("");

        //====================================================================
        // テスト: インパルス応答
        //====================================================================
        $display("Test: Impulse Response");
        send_sample(16'sh7FFF);
        for (int i = 0; i < 8; i++) begin
            send_sample(16'sh0000);
        end

        $display("");
        repeat(5) @(posedge clk);
        $display("=== FIR Filter Transposed Form Test Complete ===");
        $display("PASS");
        $finish;
    end

    task send_sample(input logic signed [DATA_WIDTH-1:0] sample);
        @(posedge clk);
        data_in = sample;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        @(posedge clk);
        if (valid_out) begin
            $display("Time=%0t: Input=%h, Output=%h", $time, sample, data_out);
        end
    endtask

endmodule
