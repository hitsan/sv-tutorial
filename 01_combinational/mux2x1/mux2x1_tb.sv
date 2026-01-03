// 2:1マルチプレクサのテストベンチ
// 複数の実装を同時にテストする

`timescale 1ns / 1ps

module mux2x1_tb;

  // ============================================================================
  // テストベンチの信号宣言
  // ============================================================================
  logic in0, in1, sel;
  logic out_assign, out_if, out_always, out_case, out_no_latch;

  // ============================================================================
  // DUT (Device Under Test) のインスタンス化
  // ============================================================================
  // 複数の実装を同時にテストして、すべてが同じ動作をすることを確認

  mux2x1_assign dut_assign (
      .in0(in0),
      .in1(in1),
      .sel(sel),
      .out(out_assign)
  );

  mux2x1_if dut_if (
      .in0(in0),
      .in1(in1),
      .sel(sel),
      .out(out_if)
  );

  mux2x1_always dut_always (
      .in0(in0),
      .in1(in1),
      .sel(sel),
      .out(out_always)
  );

  mux2x1_case dut_case (
      .in0(in0),
      .in1(in1),
      .sel(sel),
      .out(out_case)
  );

  mux2x1_no_latch dut_no_latch (
      .in0(in0),
      .in1(in1),
      .sel(sel),
      .out(out_no_latch)
  );

  // ============================================================================
  // テストシーケンス
  // ============================================================================
  initial begin
    // 波形ダンプ（シミュレータによって有効化）
    $dumpfile("mux2x1_tb.vcd");
    $dumpvars(0, mux2x1_tb);

    // テスト開始メッセージ
    $display("=================================================");
    $display("2:1 Multiplexer Test");
    $display("=================================================");
    $display("Time\tin0\tin1\tsel\tExpected\tResults");
    $display("-------------------------------------------------");

    // すべてのテストケース（真理値表の網羅）
    test_case(0, 0, 0, 0);  // sel=0 → in0を選択
    test_case(1, 0, 0, 1);  // sel=0 → in0を選択
    test_case(0, 1, 0, 0);  // sel=0 → in0を選択
    test_case(1, 1, 0, 1);  // sel=0 → in0を選択

    test_case(0, 0, 1, 0);  // sel=1 → in1を選択
    test_case(1, 0, 1, 0);  // sel=1 → in1を選択
    test_case(0, 1, 1, 1);  // sel=1 → in1を選択
    test_case(1, 1, 1, 1);  // sel=1 → in1を選択

    // テスト終了
    #10;
    $display("=================================================");
    $display("Test completed successfully!");
    $display("=================================================");
    $finish;
  end

  // ============================================================================
  // テストケース実行タスク
  // ============================================================================
  task automatic test_case(input logic t_in0, input logic t_in1, input logic t_sel,
                           input logic expected);
    begin
      // 入力を設定
      in0 = t_in0;
      in1 = t_in1;
      sel = t_sel;

      // 組み合わせ回路なので伝搬遅延を考慮
      #1;

      // 結果を表示
      $display("%0t\t%b\t%b\t%b\t%b\t\t%b %b %b %b %b", $time, in0, in1, sel, expected, out_assign,
               out_if, out_always, out_case, out_no_latch);

      // すべての実装が期待値と一致することを確認
      assert (out_assign == expected)
      else $error("assign implementation failed");
      assert (out_if == expected)
      else $error("if implementation failed");
      assert (out_always == expected)
      else $error("always implementation failed");
      assert (out_case == expected)
      else $error("case implementation failed");
      assert (out_no_latch == expected)
      else $error("no_latch implementation failed");

      // すべての実装が同じ結果を出すことを確認
      assert (out_assign == out_if && out_if == out_always &&
                    out_always == out_case && out_case == out_no_latch)
      else $error("Outputs mismatch between implementations");

      #1;  // 次のテストケースまで待機
    end
  endtask

  // ============================================================================
  // タイムアウト保護
  // ============================================================================
  initial begin
    #1000;  // 最大シミュレーション時間
    $display("ERROR: Simulation timeout!");
    $finish;
  end

  // ============================================================================
  // パラメータ化されたマルチプレクサのテスト（追加例）
  // ============================================================================
  // 8ビット幅のテスト
  logic [7:0] in0_8bit, in1_8bit, out_8bit;
  logic sel_8bit;

  mux2x1_param #(
      .WIDTH(8)
  ) dut_8bit (
      .in0(in0_8bit),
      .in1(in1_8bit),
      .sel(sel_8bit),
      .out(out_8bit)
  );

  initial begin
    // 8ビットマルチプレクサのテスト
    #100;
    $display("\n8-bit Multiplexer Test:");
    in0_8bit = 8'hAA;
    in1_8bit = 8'h55;

    sel_8bit = 0;
    #1;
    assert (out_8bit == 8'hAA)
    else $error("8-bit mux failed for sel=0");
    $display("sel=0: out = 0x%h (expected 0xAA)", out_8bit);

    sel_8bit = 1;
    #1;
    assert (out_8bit == 8'h55)
    else $error("8-bit mux failed for sel=1");
    $display("sel=1: out = 0x%h (expected 0x55)", out_8bit);
  end

endmodule : mux2x1_tb


// ============================================================================
// テストベンチ設計のポイント
// ============================================================================
// 1. すべての入力組み合わせをテスト（網羅性）
// 2. 複数の実装を同時にテストして一貫性を確認
// 3. assertを使って自動的にエラーを検出
// 4. $displayで視覚的に結果を確認
// 5. タイムアウト保護でハングを防ぐ
// 6. パラメータ化されたモジュールも別途テスト
//
// 次のステップ:
// - クロック同期テストベンチの学習 (../../tb/README.md)
// - SystemVerilog Assertionsの活用
// - カバレッジ測定
