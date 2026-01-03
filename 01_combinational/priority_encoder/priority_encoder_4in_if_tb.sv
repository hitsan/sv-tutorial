// priority_encoder_4in_if のテストベンチ
// if-else実装の全16パターンを網羅的にテストし、assertionでエラーを検出

`timescale 1ns / 100ps

module priority_encoder_4in_if_tb;

    // ============================================================================
    // テストベンチの信号宣言
    // ============================================================================
    logic [3:0] inputs;
    logic [1:0] result;
    logic       valid;

    // ============================================================================
    // DUT (Device Under Test) のインスタンス化
    // ============================================================================
    priority_encoder_4in_if DUT (.*);

    // ============================================================================
    // Golden Reference関数
    // ============================================================================
    // DUTの期待値を計算する関数
    // 最上位ビットから優先的にエンコード
    function automatic logic [1:0] calc_expected_result(logic [3:0] din);
        if (din[3]) return 2'b11;
        else if (din[2]) return 2'b10;
        else if (din[1]) return 2'b01;
        else return 2'b00;  // din[0]=1 or all 0
    endfunction

    // valid信号の期待値を計算する関数
    // 入力に少なくとも1つの'1'があればvalid=1
    function automatic logic calc_expected_valid(logic [3:0] din);
        return (din != 4'b0000);  // 全て0でなければvalid
    endfunction

    // ============================================================================
    // テストケース実行タスク
    // ============================================================================
    task automatic test_case(input logic [3:0] din);
        logic [1:0] expected_result;
        logic       expected_valid;

        // 入力を設定
        inputs = din;

        // 組み合わせ回路なので伝搬遅延を考慮
        #1;

        // 期待値を計算
        expected_result = calc_expected_result(din);
        expected_valid  = calc_expected_valid(din);

        // result が期待値と一致することを確認（===でX/Z値も厳密にチェック）
        assert (result === expected_result)
            else $error("[%0t] inputs=4'b%b: result=%b expected=%b",
                        $realtime, din, result, expected_result);

        // valid が期待値と一致することを確認
        assert (valid === expected_valid)
            else $error("[%0t] inputs=4'b%b: valid=%b expected=%b",
                        $realtime, din, valid, expected_valid);

        #1;  // 次のテストケースまで待機
    endtask

    // ============================================================================
    // テストシーケンス
    // ============================================================================
    initial begin
        // 時刻フォーマット設定
        $timeformat(-9, 0, " ns");

        // テスト開始メッセージ
        $display("=================================================");
        $display("Priority Encoder 4-input (if-else) Test");
        $display("=================================================");

        // 全16パターンをテスト（4'b0000 ～ 4'b1111）
        for (int i = 0; i < 16; i++) begin
            test_case(i[3:0]);
        end

        // テスト終了
        $display("=================================================");
        $display("Tests completed.");
        $display("=================================================");
        $finish;
    end

    // ============================================================================
    // タイムアウト保護
    // ============================================================================
    initial begin
        #1000;  // 最大シミュレーション時間
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule : priority_encoder_4in_if_tb
