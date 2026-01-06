//============================================================================
// File: sobel_filter_tb.sv
// Description: Sobelフィルタのテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns / 1ps

module sobel_filter_tb;

  localparam int CLK_PERIOD = 10;
  localparam int PIXEL_WIDTH = 8;
  localparam int IMAGE_WIDTH = 8;
  localparam int IMAGE_SIZE = IMAGE_WIDTH * IMAGE_WIDTH;

  logic                   clk;
  logic                   rst_n;
  logic [PIXEL_WIDTH-1:0] pixel_in;
  logic                   valid_in;
  logic [PIXEL_WIDTH-1:0] edge_out;
  logic                   valid_out;

  // スコアボード用
  logic [PIXEL_WIDTH-1:0] input_image    [IMAGE_SIZE];
  logic [PIXEL_WIDTH-1:0] expected_output[IMAGE_SIZE];
  logic [PIXEL_WIDTH-1:0] actual_output  [IMAGE_SIZE];
  int                     pixel_count;
  int                     output_count;
  int                     error_count;
  int                     test_count;
  int                     pass_count;

  // DUT
  sobel_filter #(
      .PIXEL_WIDTH(PIXEL_WIDTH),
      .IMAGE_WIDTH(IMAGE_WIDTH)
  ) dut (
      .clk      (clk),
      .rst_n    (rst_n),
      .pixel_in (pixel_in),
      .valid_in (valid_in),
      .edge_out (edge_out),
      .valid_out(valid_out)
  );

  // クロック生成
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // 出力モニタ
  always @(posedge clk) begin
    if (valid_out && output_count < IMAGE_SIZE) begin
      actual_output[output_count] = edge_out;
      output_count++;
    end
  end

  // テストシーケンス
  initial begin
    $dumpfile("sobel_filter_tb.vcd");
    $dumpvars(0, sobel_filter_tb);

    test_count = 0;
    pass_count = 0;

    rst_n = 0;
    pixel_in = 0;
    valid_in = 0;

    repeat (2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    $display("======================================================");
    $display("    Sobel Edge Detection Comprehensive Test");
    $display("======================================================");
    $display("Image size: %0dx%0d pixels", IMAGE_WIDTH, IMAGE_WIDTH);
    $display("Pixel width: %0d bits", PIXEL_WIDTH);
    $display("");

    // テストケース1: 垂直エッジ（左が黒、右が白）
    run_test("Vertical Edge (Left Black, Right White)",
             '{
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF
             });

    // テストケース2: 水平エッジ（上が黒、下が白）
    run_test("Horizontal Edge (Top Black, Bottom White)",
             '{
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF
             });

    // テストケース3: 均一画像（エッジなし）- 黒
    run_test("Uniform Image (All Black)",
             '{
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00
             });

    // テストケース4: 均一画像（エッジなし）- 白
    run_test("Uniform Image (All White)",
             '{
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF
             });

    // テストケース5: 対角エッジ
    run_test("Diagonal Edge",
             '{
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'hFF,
                 8'hFF
             });

    // テストケース6: チェッカーボードパターン
    run_test("Checkerboard Pattern",
             '{
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF,
                 8'h00,
                 8'hFF
             });

    // 最終結果
    $display("");
    $display("======================================================");
    $display("    Final Test Summary");
    $display("======================================================");
    $display("Total tests run: %0d", test_count);
    $display("Tests passed:    %0d", pass_count);
    $display("Tests failed:    %0d", test_count - pass_count);
    $display("======================================================");

    if (pass_count == test_count) begin
      $display("*** ALL TESTS PASSED ***");
    end else begin
      $display("*** SOME TESTS FAILED ***");
    end

    $finish;
  end

  // テスト実行タスク
  task run_test(input string test_name, input logic [PIXEL_WIDTH-1:0] image[IMAGE_SIZE]);
    int i;

    test_count++;
    $display("------------------------------------------------------");
    $display("Test #%0d: %s", test_count, test_name);
    $display("------------------------------------------------------");

    // 入力画像をコピー
    for (i = 0; i < IMAGE_SIZE; i++) begin
      input_image[i] = image[i];
    end

    // 期待値を計算
    calculate_expected_output();

    // カウンタリセット
    pixel_count  = 0;
    output_count = 0;
    error_count  = 0;

    // リセット
    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // 画像を送信
    for (i = 0; i < IMAGE_SIZE; i++) begin
      send_pixel(image[i]);
    end

    // 出力待機（パイプライン遅延を考慮）
    repeat (IMAGE_WIDTH + 10) @(posedge clk);

    // 結果を検証
    verify_output();

    $display("");
  endtask

  // ピクセル送信タスク
  task send_pixel(input logic [PIXEL_WIDTH-1:0] pixel);
    @(posedge clk);
    pixel_in = pixel;
    valid_in = 1;
    pixel_count++;
  endtask

  // 期待値計算（Sobelフィルタのリファレンス実装）
  task calculate_expected_output();
    int row, col, i, j;
    int gx, gy;
    int gradient;
    logic [PIXEL_WIDTH-1:0] p[3][3];

    for (row = 0; row < IMAGE_WIDTH; row++) begin
      for (col = 0; col < IMAGE_WIDTH; col++) begin
        // 3x3近傍を取得（境界はゼロパディング）
        for (i = 0; i < 3; i++) begin
          for (j = 0; j < 3; j++) begin
            int r = row + i - 1;
            int c = col + j - 1;
            if (r >= 0 && r < IMAGE_WIDTH && c >= 0 && c < IMAGE_WIDTH) begin
              p[i][j] = input_image[r*IMAGE_WIDTH+c];
            end else begin
              p[i][j] = 0;
            end
          end
        end

        // Sobelカーネル適用
        // Gx = [-1  0  +1]    Gy = [-1 -2 -1]
        //      [-2  0  +2]         [ 0  0  0]
        //      [-1  0  +1]         [+1 +2 +1]
        gx = -pixel_to_int(p[0][0]) + pixel_to_int(p[0][2])
             - 2 * pixel_to_int(p[1][0]) + 2 * pixel_to_int(p[1][2])
             - pixel_to_int(p[2][0]) + pixel_to_int(p[2][2]);
        gy = -pixel_to_int(p[0][0]) - 2 * pixel_to_int(p[0][1])
             - pixel_to_int(p[0][2]) + pixel_to_int(p[2][0])
             + 2 * pixel_to_int(p[2][1]) + pixel_to_int(p[2][2]);

        // 勾配強度の近似（|Gx| + |Gy|）
        gradient = abs(gx) + abs(gy);

        // 飽和処理
        if (gradient > 255) begin
          expected_output[row*IMAGE_WIDTH+col] = 8'hFF;
        end else begin
          expected_output[row*IMAGE_WIDTH+col] = gradient[PIXEL_WIDTH-1:0];
        end
      end
    end
  endtask

  // 出力検証
  task verify_output();
    int i, row, col;
    bit test_passed;

    test_passed = 1;

    for (i = 0; i < IMAGE_SIZE; i++) begin
      if (i < output_count) begin
        if (actual_output[i] !== expected_output[i]) begin
          if (error_count < 10) begin  // 最初の10個のエラーのみ表示
            row = i / IMAGE_WIDTH;
            col = i % IMAGE_WIDTH;
            $display("ERROR at [%0d,%0d]: Expected %h, Got %h", row, col, expected_output[i],
                     actual_output[i]);
          end
          error_count++;
          test_passed = 0;
        end
      end else begin
        $display("ERROR: Missing output at pixel %0d", i);
        error_count++;
        test_passed = 0;
      end
    end

    if (output_count > IMAGE_SIZE) begin
      $display("ERROR: Too many outputs (%0d expected, %0d received)", IMAGE_SIZE, output_count);
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: All %0d pixels verified correctly", IMAGE_SIZE);
      pass_count++;
    end else begin
      $display("FAIL: %0d errors detected", error_count);
      if (error_count > 10) begin
        $display("      (showing first 10 errors only)");
      end
    end
  endtask

  // 絶対値関数
  function int abs(int value);
    return (value < 0) ? -value : value;
  endfunction

  function int pixel_to_int(input logic [PIXEL_WIDTH-1:0] value);
    return int'(value);
  endfunction

endmodule
