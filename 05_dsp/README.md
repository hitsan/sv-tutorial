# デジタル信号処理 (Digital Signal Processing - DSP)

## はじめに

このディレクトリでは、デジタル信号処理の基礎となるFIRフィルタの実装を学習します。
FIR（Finite Impulse Response）フィルタは、デジタル信号処理における最も基本的かつ重要なフィルタの一つで、
音声処理、通信、画像処理など、幅広い分野で使用されています。

## 基本原則: 回路を設計してから、コードを書く

FIRフィルタの設計では、まず**フィルタ係数**と**タップ数**を決定し、
次に**構造**（直接形、転置形など）を選択してから、コードを書くことが重要です。

FIRフィルタの構造は、同じ周波数特性を持っていても、クリティカルパスや
レジスタの配置が異なるため、性能に大きな影響を与えます。

## 学習の推奨順序

### 1. FIR Filter - Direct Form (fir_filter/fir_filter_direct.sv)
- **概要**: 直接形I構造による基本的なFIRフィルタ実装
- **学習内容**:
  - シフトレジスタによる遅延線の実装
  - MAC（Multiply-Accumulate）演算
  - 固定小数点演算の基礎
  - generate文による係数の乗算
  - 加算ツリーの実装
- **重要ポイント**:
  - FIRフィルタの基本構造を理解する
  - 入力サンプルのシフト処理
  - タップ係数との乗算と累算
  - ビット幅の管理（乗算結果の拡張）
- **実装例**: 4タップFIRフィルタ、パラメータ化係数
- **ファイル**: `fir_filter/fir_filter_direct.sv`, `fir_filter/fir_filter_direct_tb.sv`

### 2. FIR Filter - Transposed Form (fir_filter/fir_filter_transposed.sv)
- **概要**: 転置形II構造によるレイテンシ削減とクリティカルパス最適化
- **学習内容**:
  - 信号フローグラフの転置
  - レジスタ配置の最適化
  - クリティカルパス削減テクニック
  - direct形との構造的な違い
- **重要ポイント**:
  - 転置形は乗算結果を即座に加算
  - レジスタが加算結果の後に配置
  - クリティカルパスが短縮される
  - 同じ周波数特性、異なる回路構造
- **実装例**: 4タップ転置形FIRフィルタ
- **ファイル**: `fir_filter/fir_filter_transposed.sv`, `fir_filter/fir_filter_transposed_tb.sv`

### 3. FIR Filter - Pipelined (fir_filter/fir_filter_pipelined.sv)
- **概要**: パイプライン化による高スループット設計
- **学習内容**:
  - パイプライン化されたMAC演算
  - 乗算と加算の間へのレジスタ挿入
  - 高クロック周波数動作の実現
  - レイテンシとスループットのトレードオフ
  - 02_sequentialで学んだパイプライン技術の応用
- **重要ポイント**:
  - レイテンシは増加するがスループットは維持
  - クリティカルパスを複数ステージに分割
  - 動作周波数の向上
  - パイプラインレジスタの配置が重要
- **実装例**: 2ステージパイプライン化FIRフィルタ
- **ファイル**: `fir_filter/fir_filter_pipelined.sv`, `fir_filter/fir_filter_pipelined_tb.sv`

## FIRフィルタの基本原理

### FIRフィルタの伝達関数

FIRフィルタの出力y[n]は、入力x[n]と係数h[k]の畳み込みで表されます：

```
y[n] = Σ h[k] * x[n-k]  (k = 0 to N-1)
```

ここで：
- N: タップ数
- h[k]: フィルタ係数
- x[n-k]: 遅延された入力サンプル

### 直接形 vs 転置形 vs パイプライン化

| 構造 | クリティカルパス | レイテンシ | スループット | 用途 |
|------|----------------|----------|------------|------|
| 直接形 | 乗算 + (N-1)加算 | 1サイクル | 1サンプル/サイクル | 基本実装 |
| 転置形 | 乗算 + 1加算 | 1サイクル | 1サンプル/サイクル | 高速動作 |
| パイプライン化 | 乗算 または 加算 | 2サイクル | 1サンプル/サイクル | 超高速動作 |

## ベストプラクティス

1. **係数のパラメータ化**: `parameter`で係数を定義し、再利用性を向上
2. **ビット幅の管理**: 乗算結果は入力ビット幅の2倍、累算は log2(N)ビット増加
3. **固定小数点演算**: Qフォーマット（例：Q1.15）を使用し、精度と範囲を管理
4. **generate文の活用**: タップ数に応じた回路を自動生成
5. **適切な構造選択**: 要求される性能に応じて直接形/転置形/パイプライン化を選択

## よくある間違いと対策

### 間違い1: ビット幅の不足（オーバーフロー）

```systemverilog
// 悪い例: ビット幅が不足
logic [7:0] coeff, sample;
logic [7:0] product;  // 16ビット必要!
assign product = coeff * sample;

// 良い例: 十分なビット幅を確保
logic [7:0] coeff, sample;
logic [15:0] product;
assign product = coeff * sample;
```

### 間違い2: 累算のビット幅不足

```systemverilog
// 悪い例: 累算でオーバーフロー
logic [15:0] sum;
sum = product0 + product1 + product2 + product3;  // 最大4倍になる

// 良い例: log2(タップ数)分のビットを追加
logic [17:0] sum;  // 15 + log2(4) = 17ビット
sum = product0 + product1 + product2 + product3;
```

### 間違い3: シフトレジスタの初期化忘れ

```systemverilog
// 悪い例: リセット処理なし
always_ff @(posedge clk) begin
    shift_reg <= {shift_reg[N-2:0], data_in};  // 初期値不定
end

// 良い例: リセット処理を追加
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        shift_reg <= '0;
    else
        shift_reg <= {shift_reg[N-2:0], data_in};
end
```

### 間違い4: 固定小数点のスケーリング忘れ

```systemverilog
// 悪い例: スケーリングなし
// Q1.7 * Q1.7 = Q2.14 だが、Q1.7に戻さない
logic [7:0] result;
result = (coeff * sample);  // 小数点位置がずれる

// 良い例: 適切にスケーリング
logic [7:0] result;
result = (coeff * sample) >>> 7;  // 7ビット右シフトでQ1.7に戻す
```

## 固定小数点演算の基礎

FIRフィルタでは通常、固定小数点演算を使用します。

### Qフォーマット表記

`Q m.n` フォーマット：
- m: 整数部のビット数
- n: 小数部のビット数
- 符号ビット: 1ビット
- 総ビット数: 1 + m + n

例：
- Q1.15 (16ビット符号付き): 範囲 [-2, 2)、精度 2^-15
- Q1.7 (8ビット符号付き): 範囲 [-2, 2)、精度 2^-7

### 演算規則

- **加算/減算**: ビット幅は変わらない（オーバーフローに注意）
- **乗算**: Q(m1.n1) × Q(m2.n2) = Q(m1+m2+1, n1+n2)
- **スケーリング**: nビット右シフトでQ(m, n+x)からQ(m+x, n)へ

## パフォーマンス比較

以下は、同じ4タップFIRフィルタの3つの実装の比較例：

| 実装 | 動作周波数（推定） | レイテンシ | リソース（推定） |
|-----|----------------|----------|---------------|
| Direct Form | 100 MHz | 1 cycle | 基準 |
| Transposed Form | 150 MHz | 1 cycle | 基準 × 1.0 |
| Pipelined | 200 MHz | 2 cycles | 基準 × 1.2 |

注：実際の値はFPGA/ASICおよび合成ツールに依存します。

## 参考資料

- Understanding Digital Signal Processing - Richard G. Lyons
- Digital Signal Processing - Alan V. Oppenheim
- IEEE 1800-2017 SystemVerilog LRM
- 詳細な説明は各ソースファイル内のコメントを参照
