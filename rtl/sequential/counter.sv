// カウンタ (Counter)
// 様々なタイプのカウンタ実装

// ============================================================================
// 基本的なアップカウンタ
// ============================================================================
module counter_up #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    output logic [WIDTH-1:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            count <= count + 1;  // インクリメント
        end
    end

    // オーバーフロー: 最大値に達すると0に戻る

endmodule : counter_up


// ============================================================================
// イネーブル付きカウンタ
// ============================================================================
module counter_enable #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,    // イネーブル
    output logic [WIDTH-1:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else if (en) begin
            count <= count + 1;  // イネーブル時のみカウント
        end
        // en=0のとき: countは保持される
    end

endmodule : counter_enable


// ============================================================================
// ロード可能なカウンタ
// ============================================================================
module counter_load #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             load,      // ロード信号
    input  logic [WIDTH-1:0] load_value,// ロード値
    output logic [WIDTH-1:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else if (load) begin
            count <= load_value;  // ロード時: 任意の値を設定
        end else begin
            count <= count + 1;   // 通常: カウントアップ
        end
    end

endmodule : counter_load


// ============================================================================
// アップ/ダウン切り替え可能カウンタ
// ============================================================================
module counter_up_down #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             up_down,  // 1=up, 0=down
    output logic [WIDTH-1:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            if (up_down) begin
                count <= count + 1;  // アップカウント
            end else begin
                count <= count - 1;  // ダウンカウント
            end
        end
    end

endmodule : counter_up_down


// ============================================================================
// 上限値付きカウンタ（モジュロカウンタ）
// ============================================================================
module counter_modulo #(
    parameter int WIDTH = 8,
    parameter int MAX_VALUE = 9  // 0~9のカウンタ例
) (
    input  logic             clk,
    input  logic             rst_n,
    output logic [WIDTH-1:0] count,
    output logic             tc     // ターミナルカウント（最大値到達）
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            if (count == MAX_VALUE) begin
                count <= '0;  // 最大値に達したら0に戻る
            end else begin
                count <= count + 1;
            end
        end
    end

    // ターミナルカウント出力
    assign tc = (count == MAX_VALUE);

    // 用途: 分周器、タイミング生成など

endmodule : counter_modulo


// ============================================================================
// 全機能搭載カウンタ
// ============================================================================
module counter_full #(
    parameter int WIDTH = 8,
    parameter int MAX_VALUE = (1 << WIDTH) - 1,  // デフォルト: 最大値
    parameter int MIN_VALUE = 0
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,        // イネーブル
    input  logic             load,      // ロード
    input  logic [WIDTH-1:0] load_value,
    input  logic             up_down,   // 1=up, 0=down
    output logic [WIDTH-1:0] count,
    output logic             tc,        // ターミナルカウント
    output logic             zero       // ゼロフラグ
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= MIN_VALUE;
        end else if (load) begin
            count <= load_value;
        end else if (en) begin
            if (up_down) begin
                // アップカウント
                if (count == MAX_VALUE) begin
                    count <= MIN_VALUE;  // ラップアラウンド
                end else begin
                    count <= count + 1;
                end
            end else begin
                // ダウンカウント
                if (count == MIN_VALUE) begin
                    count <= MAX_VALUE;  // ラップアラウンド
                end else begin
                    count <= count - 1;
                end
            end
        end
    end

    // ステータスフラグ
    assign tc = up_down ? (count == MAX_VALUE) : (count == MIN_VALUE);
    assign zero = (count == '0);

endmodule : counter_full


// ============================================================================
// BCD (Binary Coded Decimal) カウンタ
// ============================================================================
module counter_bcd (
    input  logic       clk,
    input  logic       rst_n,
    output logic [3:0] ones,   // 1の位 (0-9)
    output logic [3:0] tens,   // 10の位 (0-9)
    output logic       tc      // 99到達
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ones <= 4'd0;
            tens <= 4'd0;
        end else begin
            if (ones == 4'd9) begin
                ones <= 4'd0;
                if (tens == 4'd9) begin
                    tens <= 4'd0;  // 99 → 00
                end else begin
                    tens <= tens + 1;
                end
            end else begin
                ones <= ones + 1;
            end
        end
    end

    assign tc = (ones == 4'd9) && (tens == 4'd9);

endmodule : counter_bcd


// ============================================================================
// ワンホットカウンタ（1ビットのみ'1'）
// ============================================================================
module counter_one_hot #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    output logic [WIDTH-1:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= {{(WIDTH-1){1'b0}}, 1'b1};  // 初期値: 000...001
        end else begin
            // 左シフト、最上位ビットは最下位へ
            count <= {count[WIDTH-2:0], count[WIDTH-1]};
        end
    end

    // リングカウンタとも呼ばれる
    // 用途: ステートマシン、タイミング生成

endmodule : counter_one_hot


// ============================================================================
// グレイコードカウンタ
// ============================================================================
module counter_gray #(
    parameter int WIDTH = 4
) (
    input  logic             clk,
    input  logic             rst_n,
    output logic [WIDTH-1:0] gray
);
    logic [WIDTH-1:0] binary;

    // バイナリカウンタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            binary <= '0;
        end else begin
            binary <= binary + 1;
        end
    end

    // バイナリからグレイコードへ変換
    assign gray = binary ^ (binary >> 1);

    // グレイコードの特徴:
    // - 連続する値で1ビットのみ変化
    // - 非同期回路での使用に適する（クロックドメイン間など）

endmodule : counter_gray


// ============================================================================
// リング発振カウンタ（分周器）
// ============================================================================
module counter_divider #(
    parameter int DIVISOR = 10  // 分周比
) (
    input  logic clk_in,
    input  logic rst_n,
    output logic clk_out
);
    localparam int COUNTER_WIDTH = $clog2(DIVISOR);
    logic [COUNTER_WIDTH-1:0] count;

    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
            clk_out <= 1'b0;
        end else begin
            if (count == DIVISOR - 1) begin
                count <= '0;
                clk_out <= ~clk_out;  // トグル
            end else begin
                count <= count + 1;
            end
        end
    end

    // 注意: この方法は厳密なクロック分周には不適切
    // 理由: clk_outが組み合わせ回路を経由する可能性
    // 推奨: イネーブル信号を生成し、元のクロックを使用

endmodule : counter_divider


// ============================================================================
// 学習ポイントまとめ
// ============================================================================
// 1. カウンタの基本: count <= count + 1
// 2. イネーブル: カウント制御
// 3. ロード: 任意の値から開始
// 4. 上限/下限: ラップアラウンド動作
// 5. ステータスフラグ: tc, zero などの補助出力
// 6. 特殊カウンタ: BCD, ワンホット, グレイコード
// 7. 分周器: カウンタを使った周波数分周
//
// 応用例:
// - タイマー、ストップウォッチ
// - 周波数分周器
// - アドレス生成
// - ステートマシンのタイムアウト検出
