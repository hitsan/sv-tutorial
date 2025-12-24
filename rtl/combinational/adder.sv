// 加算器 (Adder)
// 様々なタイプの加算器実装

// ============================================================================
// 基本的な加算器（キャリーなし）
// ============================================================================
module adder_simple #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum
);
    // 最もシンプルな加算
    // キャリーアウトは無視される（切り捨て）
    assign sum = a + b;

endmodule : adder_simple


// ============================================================================
// キャリーアウト付き加算器
// ============================================================================
module adder_cout #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum,
    output logic             cout  // キャリーアウト
);
    // 方法1: 中間変数を使用
    logic [WIDTH:0] temp_sum;  // WIDTH+1ビット必要

    assign temp_sum = a + b;   // WIDTH+1ビットの加算結果
    assign sum = temp_sum[WIDTH-1:0];  // 下位WIDTHビット
    assign cout = temp_sum[WIDTH];      // 最上位ビット（キャリー）

endmodule : adder_cout


// ============================================================================
// キャリーアウト付き加算器（連結演算子使用）
// ============================================================================
module adder_cout_concat #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum,
    output logic             cout
);
    // 方法2: 連結演算子を使用
    // {cout, sum} は (WIDTH+1)ビットのベクタを形成
    assign {cout, sum} = a + b;

    // 注意: 右辺は自動的に(WIDTH+1)ビットに拡張される

endmodule : adder_cout_concat


// ============================================================================
// キャリーイン/アウト付き加算器
// ============================================================================
module adder_cin_cout #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,   // キャリーイン
    output logic [WIDTH-1:0] sum,
    output logic             cout   // キャリーアウト
);
    // キャリーインを含めた加算
    assign {cout, sum} = a + b + cin;

    // 複数ワードの加算に使用可能
    // 例: 16ビット = 8ビット加算器 × 2段

endmodule : adder_cin_cout


// ============================================================================
// オーバーフロー検出付き加算器（符号付き）
// ============================================================================
module adder_overflow_signed #(
    parameter int WIDTH = 8
) (
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [WIDTH-1:0] sum,
    output logic                    overflow  // オーバーフロー検出
);
    // 符号付き加算
    assign sum = a + b;

    // オーバーフロー検出ロジック（符号付き）
    // 正 + 正 = 負 または 負 + 負 = 正 の場合にオーバーフロー
    assign overflow = (a[WIDTH-1] == b[WIDTH-1]) &&
                      (sum[WIDTH-1] != a[WIDTH-1]);

    // 詳細な説明:
    // - 同符号同士の加算のみオーバーフロー可能性あり
    // - 結果の符号が入力と異なればオーバーフロー

endmodule : adder_overflow_signed


// ============================================================================
// オーバーフロー検出付き加算器（符号なし）
// ============================================================================
module adder_overflow_unsigned #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum,
    output logic             overflow  // オーバーフロー（符号なし）
);
    logic cout;

    assign {cout, sum} = a + b;

    // 符号なしのオーバーフローはキャリーアウトと同じ
    assign overflow = cout;

endmodule : adder_overflow_unsigned


// ============================================================================
// 全機能搭載加算器
// ============================================================================
module adder_full #(
    parameter int WIDTH = 8,
    parameter bit SIGNED = 0  // 0=符号なし, 1=符号付き
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic [WIDTH-1:0] sum,
    output logic             cout,
    output logic             overflow
);
    // 加算実行
    assign {cout, sum} = a + b + cin;

    // オーバーフロー検出（signed/unsigned切り替え）
    generate
        if (SIGNED) begin : signed_overflow
            // 符号付きオーバーフロー検出
            assign overflow = (a[WIDTH-1] == b[WIDTH-1]) &&
                              (sum[WIDTH-1] != a[WIDTH-1]);
        end else begin : unsigned_overflow
            // 符号なしオーバーフロー検出（キャリーアウト）
            assign overflow = cout;
        end
    endgenerate

endmodule : adder_full


// ============================================================================
// 複数ワード加算器（16ビット = 8ビット×2段の例）
// ============================================================================
module adder_16bit (
    input  logic [15:0] a,
    input  logic [15:0] b,
    output logic [15:0] sum,
    output logic        cout
);
    logic carry_mid;  // 中間キャリー

    // 下位8ビット加算
    adder_cin_cout #(.WIDTH(8)) adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .cin(1'b0),           // 最下位のキャリーインは0
        .sum(sum[7:0]),
        .cout(carry_mid)      // 中間キャリー
    );

    // 上位8ビット加算
    adder_cin_cout #(.WIDTH(8)) adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(carry_mid),      // 下位からのキャリー
        .sum(sum[15:8]),
        .cout(cout)           // 最終キャリーアウト
    );

endmodule : adder_16bit


// ============================================================================
// 減算器（2の補数を利用）
// ============================================================================
module subtractor #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] diff,  // 差分
    output logic             borrow // ボロー（借り）
);
    // 減算は a - b = a + (~b) + 1（2の補数）
    logic cout;

    assign {cout, diff} = a + (~b) + 1'b1;

    // ボローはキャリーアウトの反転
    assign borrow = ~cout;

endmodule : subtractor


// ============================================================================
// 加減算器（モード切り替え可能）
// ============================================================================
module adder_subtractor #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             mode,  // 0=加算, 1=減算
    output logic [WIDTH-1:0] result,
    output logic             cout
);
    // mode=0: a + b
    // mode=1: a - b = a + (~b) + 1

    logic [WIDTH-1:0] b_modified;

    // modeに応じてbを反転
    assign b_modified = mode ? ~b : b;

    // 加算実行（減算時はcinに1を入れて2の補数を完成）
    assign {cout, result} = a + b_modified + mode;

endmodule : adder_subtractor


// ============================================================================
// 学習ポイントまとめ
// ============================================================================
// 1. 基本加算: a + b で簡単に記述可能
// 2. キャリー処理: {cout, sum} = a + b; で同時取得
// 3. 符号付き演算: signed修飾子を使用
// 4. オーバーフロー: 符号付きと符号なしで検出方法が異なる
// 5. 2の補数: 減算は加算器で実装可能（~b + 1）
// 6. パラメータ化: WIDTHパラメータで汎用性向上
// 7. generate文: SIGNED切り替えなどに活用
//
// 重要な注意点:
// - ビット幅の不一致に注意（合成警告の原因）
// - 符号拡張を正しく行う
// - キャリー/オーバーフローの扱いを理解する
