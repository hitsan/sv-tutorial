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
    parameter int WIDTH = 8,  // 各入力のビット幅
    parameter int N     = 4   // 入力の数（2のべき乗を推奨）
) (
    input  logic [WIDTH-1:0] in [N-1:0],  // N個の入力
    output logic [WIDTH-1:0] sum          // 合計
);
  localparam int LEVELS = $clog2(N);
  logic [WIDTH-1:0] level[0:LEVELS][0:N-1];

  always_comb begin
    for (int l = 0; l <= LEVELS; l++) begin
      for (int i = 0; i < N; i++) begin
        level[l][i] = '0;
      end
    end
    for (int i = 0; i < N; i++) begin
      level[0][i] = in[i];
    end
    for (int l = 0; l < LEVELS; l++) begin
      for (int j = 0; j < (N >> (l + 1)); j++) begin
        level[l+1][j] = level[l][2*j] + level[l][2*j+1];
      end
    end
  end

  assign sum = level[LEVELS][0];

endmodule : adder_tree
