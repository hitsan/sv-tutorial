// 演習2: generate構文
// リップルキャリー加算器の実装

/*
 * 要求仕様:
 * - 8ビットのリップルキャリー加算器を実装
 * - 1ビット全加算器を`for generate`で連鎖
 * - 全加算器モジュール（full_adder）を定義して使用
 *
 * 構造:
 *    a[0] b[0]        a[1] b[1]              a[7] b[7]
 *      │   │            │   │                  │   │
 *    ┌─┴───┴─┐        ┌─┴───┴─┐            ┌─┴───┴─┐
 *    │  FA0  │        │  FA1  │            │  FA7  │
 *  ──┤cin    │c[1]  ──┤cin    │         ───┤cin    │
 *    │  cout├────────→│  cout├─── ... ────→│  cout├─→ cout
 *    └───┬───┘        └───┬───┘            └───┬───┘
 *      sum[0]           sum[1]               sum[7]
 */

// 1ビット全加算器（この定義は提供）
module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign {cout, sum} = a + b + cin;
endmodule : full_adder

// 8ビットリップルキャリー加算器
module ripple_carry_adder_8bit (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
    // ここに実装
    // ヒント:
    // 1. logic [8:0] carry; でキャリー信号を宣言
    // 2. carry[0] = cin;
    // 3. for generate で full_adder を8個インスタンス化
    // 4. cout = carry[8];

endmodule : ripple_carry_adder_8bit
