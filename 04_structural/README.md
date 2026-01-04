# 構造記述 (Structural Description)

## はじめに

構造記述とは、回路図をコードで表現したものです。
既存のコンポーネント（モジュール）を接続することで、より大きな回路を構築します。

## 基本原則: 回路図を設計してから、コードを書く

構造記述では、「回路設計」とは回路図を作成することです。
回路図の各コンポーネントに対して、既存のモジュールをインスタンス化し、
回路図に示されているように接続していきます。

構造記述における主な創造性は、回路図のパターン（または例外）を
`generate`構文で記述できるように識別することです。

## 学習の推奨順序

### 1. 基本的なモジュールインスタンス化 (module_inst/)
- **概要**: 既存のモジュールを接続して、より大きな回路を構築する基本的な手法
- **学習内容**:
  - モジュールのインスタンス化
  - 名前付きポート接続
  - 位置ベースポート接続
- **実装例**: 4:1マルチプレクサの構造記述
- **ファイル**: `module_inst/`

### 2. generate構文 (generate_example/)
- **概要**: 繰り返しや条件によって回路構造を動的に生成する構文
- **学習内容**:
  - `for generate` - 繰り返しパターン
  - `if generate` - 条件付き生成
  - `case generate` - 選択的生成
- **実装例**: リップルキャリー加算器
- **ファイル**: `generate_example/`

### 3. パラメータ化 (param_design/)
- **概要**: パラメータを使って柔軟で再利用可能な回路を設計する手法
- **学習内容**:
  - パラメータオーバーライド
  - `localparam`の使用
  - `$clog2`などのシステム関数
- **実装例**: パラメータ化された加算器ツリー
- **ファイル**: `param_design/`

## インスタンス化の基本

### 名前付き接続（推奨）
```systemverilog
// 明示的でエラーが少ない
adder u_adder (
    .a(input_a),
    .b(input_b),
    .sum(result),
    .cout(carry)
);
```

### 位置ベース接続（非推奨）
```systemverilog
// 順序間違いのリスクあり
adder u_adder (input_a, input_b, result, carry);
```

### パラメータ付きインスタンス化
```systemverilog
// 方法1: 名前付き
adder #(.WIDTH(16)) u_adder16 (
    .a(a), .b(b), .sum(sum), .cout(cout)
);

// 方法2: 位置ベース
adder #(16) u_adder16 (
    .a(a), .b(b), .sum(sum), .cout(cout)
);
```

## generate構文

### for generate（繰り返しパターン）
```systemverilog
generate
    for (genvar i = 0; i < 4; i++) begin : gen_adder
        adder u_adder (
            .a(a[i]),
            .b(b[i]),
            .sum(sum[i]),
            .cout(carry[i+1])
        );
    end
endgenerate
```

### if generate（条件付き生成）
```systemverilog
generate
    if (USE_FAST_ADDER) begin : fast_adder
        carry_lookahead_adder u_adder (...);
    end else begin : ripple_adder
        ripple_carry_adder u_adder (...);
    end
endgenerate
```

### case generate（選択的生成）
```systemverilog
generate
    case (ADDER_TYPE)
        "RIPPLE": ripple_carry_adder u_adder (...);
        "CLA":    carry_lookahead_adder u_adder (...);
        "CSA":    carry_select_adder u_adder (...);
    endcase
endgenerate
```

## ベストプラクティス

1. **名前付き接続を使用**: 可読性とメンテナンス性向上
2. **ラベルを付ける**: generate ブロックには必ずラベル
3. **パラメータで汎用化**: 再利用性を高める
4. **階層的な設計**: 小さなモジュールから構築
5. **命名規則**: インスタンス名は`u_`、generate は`gen_`

## よくあるパターン

### パターン1: リップルキャリー加算器
```systemverilog
// 1ビット全加算器を連鎖
generate
    for (genvar i = 0; i < WIDTH; i++) begin : gen_fa
        full_adder u_fa (
            .a(a[i]),
            .b(b[i]),
            .cin(carry[i]),
            .sum(sum[i]),
            .cout(carry[i+1])
        );
    end
endgenerate
```

### パターン2: ツリー構造
```systemverilog
// 加算器ツリー（並列削減）
generate
    for (genvar level = 0; level < LEVELS; level++) begin : gen_level
        for (genvar i = 0; i < (N >> (level+1)); i++) begin : gen_adder
            adder u_adder (
                .a(data[level][i*2]),
                .b(data[level][i*2+1]),
                .sum(data[level+1][i])
            );
        end
    end
endgenerate
```

### パターン3: 条件付きコンポーネント
```systemverilog
// オプション機能
generate
    if (ENABLE_PARITY) begin : gen_parity
        parity_checker u_parity (...);
    end
endgenerate
```
