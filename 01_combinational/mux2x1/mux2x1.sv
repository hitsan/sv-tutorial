// 2:1 マルチプレクサ (2-to-1 Multiplexer)
// 様々な記述方法を示すサンプル

// ============================================================================
// 方法1: assign文による記述（最もシンプル）
// ============================================================================
module mux2x1_assign (
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);
  // 三項演算子を使用した連続代入
  // sel=1のときin1、sel=0のときin0を出力
  assign out = sel ? in1 : in0;

  // 明示的な比較も可能
  // assign out = (sel == 1'b1) ? in1 : in0;

endmodule : mux2x1_assign


// ============================================================================
// 方法2: always_combブロックとif文
// ============================================================================
module mux2x1_if (
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);
  // always_comb: 組み合わせ回路専用のブロック
  // - 自動的に感度リストを生成（in0, in1, selの変化を検知）
  // - ブロッキング代入(=)を使用
  // - VHDL 2008の process(all) に相当

  always_comb begin
    if (sel == 1'b0) begin
      out = in0;
    end else begin
      out = in1;
    end
  end

  // シンプルな書き方（begin-endは省略可能）
  // always_comb
  //     if (sel) out = in1;
  //     else out = in0;

endmodule : mux2x1_if


// ============================================================================
// 方法3: always @(*) ブロック（古いスタイル）
// ============================================================================
module mux2x1_always (
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);
  // always @(*): 汎用的なalwaysブロック
  // - (*) は右辺の全信号を感度リストに含める
  // - always_combより古い書き方だが、まだ広く使われている

  always @(*) begin
    if (sel == 1'b0) begin
      out = in0;
    end else begin
      out = in1;
    end
  end

  // 注意: always @(sel, in0, in1) のように明示的に書くと
  // 信号を追加したときに更新忘れのバグが発生しやすい

endmodule : mux2x1_always


// ============================================================================
// 方法4: case文による記述
// ============================================================================
module mux2x1_case (
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);
  // case文: 複数の選択肢がある場合に便利
  // 2:1 muxではif文の方が自然だが、学習のため示す

  always_comb begin
    case (sel)
      1'b0: out = in0;
      1'b1: out = in1;
      default: out = 1'bx;  // 本来は起こらないが、完全性のため
    endcase
  end

  // case文のバリエーション:
  // - case: 等価比較（===）、x/zも厳密に比較
  // - casez: z(?)をdon't careとして扱う
  // - casex: x/z両方をdon't careとして扱う（非推奨）

endmodule : mux2x1_case


// ============================================================================
// 方法5: ラッチを意図的に避ける例
// ============================================================================
module mux2x1_no_latch (
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);
  // ベストプラクティス: デフォルト値を設定してラッチを防ぐ

  always_comb begin
    // デフォルト値を先に設定
    out = in0;

    // 条件に応じて上書き
    if (sel == 1'b1) begin
      out = in1;
    end
    // else節がなくてもラッチは生成されない（デフォルト値があるため）
  end

endmodule : mux2x1_no_latch


// ============================================================================
// 発展例: パラメータ化された幅可変マルチプレクサ
// ============================================================================
module mux2x1_param #(
    parameter int WIDTH = 8  // データ幅をパラメータ化
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             sel,
    output logic [WIDTH-1:0] out
);
  // パラメータを使うことで、任意のビット幅に対応可能
  assign out = sel ? in1 : in0;

  // 使用例:
  // mux2x1_param #(.WIDTH(32)) mux32 (.in0(a), .in1(b), .sel(s), .out(y));
  // mux2x1_param #(16) mux16 (.in0(c), .in1(d), .sel(s), .out(z));

endmodule : mux2x1_param


// ============================================================================
// よくある間違い例（コメントアウト）
// ============================================================================
/*
module mux2x1_bad_latch (
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);
    // 間違い1: 不完全な条件分岐 → ラッチが生成される!
    always_comb begin
        if (sel == 1'b1) begin
            out = in1;
        end
        // else節がないため、sel=0のときoutは前の値を保持 → ラッチ!
    end
endmodule

module mux2x1_bad_sensitivity (
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);
    // 間違い2: 不完全な感度リスト（古いスタイルで発生しやすい）
    always @(sel, in0) begin  // in1が抜けている!
        if (sel) out = in1;
        else out = in0;
        // 合成は正しいがシミュレーション結果が不正確になる
    end
    // 対策: always_combを使う、または @(*) を使う
endmodule
*/

// ============================================================================
// 学習ポイントまとめ
// ============================================================================
// 1. assign文: 単純な組み合わせ回路に最適
// 2. always_comb: 複雑な組み合わせ回路に推奨（感度リスト自動生成）
// 3. if文: 優先度がある選択に適している
// 4. case文: 等価比較による選択に適している
// 5. デフォルト値設定: ラッチ生成を防ぐ重要なテクニック
// 6. パラメータ: 再利用性と汎用性を高める
