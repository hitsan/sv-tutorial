// 演習3: パラメータ化
// パラメータ化された加算器ツリー

/*
 * 要求仕様:
 * - N個の入力を並列に加算するツリー構造
 * - パラメータでビット幅と入力数を指定可能
 * - 2入力加算器を使用してツリー構造で削減
 *
 * 例: N=4の場合
 *    in[0]  in[1]  in[2]  in[3]
 *      │      │      │      │
 *      └──┬───┘      └──┬───┘   Level 0
 *         │             │
 *      level0[0]    level0[1]
 *         │             │
 *         └──────┬──────┘       Level 1
 *                │
 *             result
 *
 * N=8の場合は3レベルのツリー、N=16の場合は4レベル
 */

// パラメータ化された加算器ツリー
module adder_tree #(
    parameter int WIDTH = 8,   // 各入力のビット幅
    parameter int N = 4        // 入力の数（2のべき乗を推奨）
) (
    input  logic [WIDTH-1:0] in [N-1:0],  // N個の入力
    output logic [WIDTH-1:0] sum          // 合計
);
    // ここに実装
    // ヒント:
    // 1. localparam LEVELS = $clog2(N); でレベル数を計算
    // 2. logic [WIDTH-1:0] level [LEVELS:0] [N-1:0]; で各レベルのデータを宣言
    // 3. level[0] = in; で初期化
    // 4. 2重ループのfor generateでツリー構造を生成
    //    外側: レベル (0からLEVELS-1)
    //    内側: 各レベルの加算器 (0から(N>>(level+1))-1)
    // 5. sum = level[LEVELS][0]; で最終結果

endmodule : adder_tree
