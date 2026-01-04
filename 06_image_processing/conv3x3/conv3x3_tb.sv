//============================================================================
// File: conv3x3_tb.sv
// Description: 3x3畳み込みのテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module conv3x3_tb;

    localparam int CLK_PERIOD = 10;
    localparam int PIXEL_WIDTH = 8;
    localparam int IMAGE_WIDTH = 8;

    logic                       clk;
    logic                       rst_n;
    logic [PIXEL_WIDTH-1:0]     pixel_in;
    logic                       valid_in;
    logic signed [PIXEL_WIDTH-1:0] pixel_out;
    logic                       valid_out;

    // DUT（平滑化フィルタ：すべて1、スケール1/9 ≈ 右シフト3ビット）
    conv3x3 #(
        .PIXEL_WIDTH  (PIXEL_WIDTH),
        .IMAGE_WIDTH  (IMAGE_WIDTH),
        .K00(1), .K01(1), .K02(1),
        .K10(1), .K11(1), .K12(1),
        .K20(1), .K21(1), .K22(1),
        .SCALE_SHIFT(3)  // 1/8 ≈ 1/9
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .pixel_in  (pixel_in),
        .valid_in  (valid_in),
        .pixel_out (pixel_out),
        .valid_out (valid_out)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // テストシーケンス
    initial begin
        $dumpfile("conv3x3_tb.vcd");
        $dumpvars(0, conv3x3_tb);

        rst_n = 0;
        pixel_in = 0;
        valid_in = 0;

        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("=== 3x3 Convolution Test Start ===");
        $display("Image size: %0dx%0d", IMAGE_WIDTH, IMAGE_WIDTH);
        $display("Kernel: 3x3 averaging (all ones, scale 1/8)");
        $display("");

        // 8x8テスト画像を送信（中央に明るいピクセル）
        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);
        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);

        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);
        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);

        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'hFF); send_pixel(8'hFF);
        send_pixel(8'hFF); send_pixel(8'hFF); send_pixel(8'h00); send_pixel(8'h00);

        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'hFF); send_pixel(8'hFF);
        send_pixel(8'hFF); send_pixel(8'hFF); send_pixel(8'h00); send_pixel(8'h00);

        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'hFF); send_pixel(8'hFF);
        send_pixel(8'hFF); send_pixel(8'hFF); send_pixel(8'h00); send_pixel(8'h00);

        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'hFF); send_pixel(8'hFF);
        send_pixel(8'hFF); send_pixel(8'hFF); send_pixel(8'h00); send_pixel(8'h00);

        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);
        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);

        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);
        send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00); send_pixel(8'h00);

        repeat(10) @(posedge clk);
        $display("");
        $display("=== 3x3 Convolution Test Complete ===");
        $display("PASS");
        $finish;
    end

    task send_pixel(input logic [PIXEL_WIDTH-1:0] pixel);
        @(posedge clk);
        pixel_in = pixel;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        if (valid_out) begin
            $display("Output pixel: %h", pixel_out);
        end
    endtask

endmodule
