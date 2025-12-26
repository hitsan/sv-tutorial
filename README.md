# SystemVerilog 学習教材

SystemVerilogによるRTL設計と検証を体系的に学習するための教材です。
基礎から応用まで、実践的なサンプルコードと詳細な解説を提供します。

## 📚 教材の特徴

- **体系的な学習パス**: 基礎から段階的にステップアップ
- **厳選されたサンプルコード**: 重要な基礎を押さえた実装例
- **豊富な演習問題**: 実践を通じて理解を深める
- **詳細な解説**: コメントとREADMEで理解を深める
- **ベストプラクティス**: 業界標準のコーディングスタイル
- **よくある間違い**: 陥りやすいミスとその対策

### 学習スタイル

この教材は **サンプルコード + 演習問題** の構成です：

- **✓ サンプル実装済み**: 重要な基礎となる実装例を提供
- **📝 演習問題**: サンプルを参考に自分で実装して理解を深める

すべてを提供するのではなく、基礎となるサンプルから学び、
応用は自分で実装することで実践力を養います。

## 📁 ディレクトリ構造による学習

このリポジトリは**ディレクトリ構造**で教材を整理しています：

### 3段階の学習ステップ

各カテゴリ（combinational, sequential, fsm, structural）には、以下の3つのディレクトリがあります：

#### 1. `examples/` - サンプルコード
- **実装済みの基礎サンプル**（mux2x1.sv, adder.sv, register.sv等）
- まずこれらを読んで理解する

#### 2. `exercises/` - 演習問題
- **自分で実装する演習問題**（スケルトンまたは未作成）
- サンプルを参考に自分で実装

#### 3. `solutions/` - 解答例
- **演習問題の解答例**
- 詰まったとき、実装方法を確認したいときに参照

### ディレクトリ例

```
rtl/
├── combinational/
│   ├── examples/       # mux2x1.sv, adder.sv（実装済み）
│   ├── exercises/      # 演習問題（自分で実装）
│   ├── solutions/      # 解答例
│   └── README.md
├── sequential/
│   ├── examples/       # register.sv, counter.sv
│   ├── exercises/
│   ├── solutions/
│   └── README.md
└── ...
```

### 学習のコツ

1. **まず examples/ のサンプルコードを読んで理解する**
2. **exercises/ で自分で実装してみる**
3. **詰まったら examples/ を参照する**
4. **それでも分からなければ solutions/ を確認する**
5. **解答例を見た後は、理解して自分で再実装する**

### クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/hitsan/sv-tutorial.git
cd sv-tutorial

# サンプルコードから学習開始
cd rtl/combinational/examples
# mux2x1.sv を読んで理解

# 演習問題に取り組む
cd ../exercises
# ここで自分で実装

# 解答例を参照（必要に応じて）
cd ../solutions
```

## 🗂️ ディレクトリ構成

```
sv-tutorial/
├── rtl/                    # RTL設計（合成可能なコード）
│   ├── combinational/      # 組み合わせ回路
│   │   ├── examples/       # サンプルコード（実装済み）
│   │   ├── exercises/      # 演習問題（自分で実装）
│   │   ├── solutions/      # 解答例
│   │   └── README.md
│   ├── sequential/         # 順序回路（レジスタ、カウンタ等）
│   │   ├── examples/
│   │   ├── exercises/
│   │   ├── solutions/
│   │   └── README.md
│   ├── fsm/                # 有限ステートマシン
│   │   ├── examples/
│   │   ├── exercises/
│   │   ├── solutions/
│   │   └── README.md
│   └── structural/         # 構造記述
│       ├── examples/
│       ├── exercises/
│       ├── solutions/
│       └── README.md
│
├── tb/                     # テストベンチと検証
│   └── README.md           # テストベンチ基礎
│
├── sim/                    # シミュレーション環境
├── syn/                    # 合成スクリプト・制約
├── doc/                    # 追加ドキュメント
├── scripts/                # ビルド・検証スクリプト
├── ip/                     # IPコア
└── ref/                    # 参考資料（外部リポジトリ）
```

## 🎯 学習パス

### レベル1: 基礎編（初学者向け）

#### 1. 組み合わせ回路 (Combinational Logic)
**ディレクトリ**: `rtl/combinational/`

基本的な論理回路の記述方法を学習します。

- **学習内容**:
  - `assign`文と`always_comb`ブロック
  - マルチプレクサ、エンコーダ、デコーダ
  - 加算器、乗算器、ALU
  - ラッチ回避のテクニック

- **重要ファイル**:
  - `mux2x1.sv` - 基本的なマルチプレクサ（複数実装方法）
  - `adder.sv` - 各種加算器の実装
  - `README.md` - 詳細な学習ガイド

- **学習時間**: 1-2週間

#### 2. 順序回路 (Sequential Logic)
**ディレクトリ**: `rtl/sequential/`

クロック同期回路とレジスタの記述を学習します。

- **学習内容**:
  - レジスタとフリップフロップ
  - 同期/非同期リセット
  - カウンタ、シフトレジスタ
  - ブロッキング vs ノンブロッキング代入

- **重要ファイル**:
  - `register.sv` - 各種レジスタ実装
  - `counter.sv` - カウンタのバリエーション
  - `README.md` - 順序回路設計の原則

- **学習時間**: 2-3週間

#### 3. 有限ステートマシン (FSM)
**ディレクトリ**: `rtl/fsm/`

制御ロジックの中核となるFSMを学習します。

- **学習内容**:
  - Moore型 vs Mealy型
  - 1プロセス vs 2プロセスモデル
  - 状態エンコーディング
  - FSM設計パターン

- **重要ファイル**:
  - `moore_fsm.sv` - Moore型の実装例
  - `README.md` - FSM設計ガイド

- **学習時間**: 2-3週間

#### 4. 構造記述 (Structural Description)
**ディレクトリ**: `rtl/structural/`

モジュールの階層化と再利用を学習します。

- **学習内容**:
  - モジュールインスタンス化
  - `generate`構文
  - パラメータ化設計
  - 階層的設計手法

- **重要ファイル**:
  - `README.md` - 構造記述の基本

- **学習時間**: 1-2週間

### レベル2: 検証編

#### 5. テストベンチ基礎
**ディレクトリ**: `tb/`

設計の検証手法を学習します。

- **学習内容**:
  - 基本的なテストベンチ構造
  - クロックとリセット生成
  - タスクと関数
  - アサーション
  - カバレッジ

- **重要ファイル**:
  - `README.md` - テストベンチ設計ガイド
  - 各RTLモジュールの`*_tb.sv`ファイル

- **学習時間**: 2-3週間

### レベル3: 応用編（中級者向け）

- メモリインターフェース設計
- バスプロトコル（AXI, Avalon等）
- パイプライン設計
- タイミングクロージャー
- 低消費電力設計

## 🚀 クイックスタート

### 1. 環境セットアップ

以下のいずれかのシミュレータが必要です：

- **オープンソース**:
  - Icarus Verilog + GTKWave
  - Verilator

- **商用ツール**:
  - Synopsys VCS
  - Mentor Questa/ModelSim
  - Cadence Xcelium
  - Xilinx Vivado Simulator
  - Intel Quartus Prime

### 2. 最初のシミュレーション

#### 例: 2:1マルチプレクサ

```bash
# Icarus Verilogの場合
cd rtl/combinational/examples
iverilog -g2012 -o mux2x1.vvp mux2x1.sv mux2x1_tb.sv
vvp mux2x1.vvp
gtkwave mux2x1_tb.vcd

# VCSの場合
vcs -sverilog +v2k -debug_access+all mux2x1.sv mux2x1_tb.sv
./simv

# Questa/ModelSimの場合
vlog -sv mux2x1.sv mux2x1_tb.sv
vsim -c work.mux2x1_tb -do "run -all; quit"
```

### 3. 推奨学習順序

1. `rtl/combinational/README.md` を読む
2. `rtl/combinational/examples/mux2x1.sv` のコードを理解
3. `rtl/combinational/examples/mux2x1_tb.sv` でシミュレーション
4. 各READMEの推奨順序に従って学習を進める

## 📖 各章の詳細

### 組み合わせ回路 (Combinational)

| 状態 | トピック | ディレクトリ | 難易度 | 学習時間 |
|------|---------|-------------|--------|----------|
| ✓ | 2:1 Mux | `examples/mux2x1.sv` | ⭐ | 1-2時間 |
| ✓ | 加算器 | `examples/adder.sv` | ⭐⭐ | 2-3時間 |
| 📝 | プライオリティエンコーダ | `exercises/` → `solutions/` | ⭐⭐ | 2-3時間 |
| 📝 | 乗算器 | `exercises/` → `solutions/` | ⭐⭐⭐ | 3-4時間 |
| 📝 | ALU | `exercises/` → `solutions/` | ⭐⭐⭐ | 3-4時間 |

### 順序回路 (Sequential)

| 状態 | トピック | ディレクトリ | 難易度 | 学習時間 |
|------|---------|-------------|--------|----------|
| ✓ | レジスタ | `examples/register.sv` | ⭐⭐ | 2-3時間 |
| ✓ | カウンタ | `examples/counter.sv` | ⭐⭐ | 2-3時間 |
| 📝 | シフトレジスタ | `exercises/` → `solutions/` | ⭐⭐ | 2-3時間 |
| 📝 | FIFO | `exercises/` → `solutions/` | ⭐⭐⭐ | 4-5時間 |

### FSM

| 状態 | トピック | ディレクトリ | 難易度 | 学習時間 |
|------|---------|-------------|--------|----------|
| ✓ | Moore FSM | `examples/moore_fsm.sv` | ⭐⭐⭐ | 3-4時間 |
| 📝 | Mealy FSM | `exercises/` → `solutions/` | ⭐⭐⭐ | 3-4時間 |
| 📝 | UART制御 | `exercises/` → `solutions/` | ⭐⭐⭐⭐ | 5-6時間 |

### 構造記述 (Structural)

| 状態 | トピック | ディレクトリ | 難易度 | 学習時間 |
|------|---------|-------------|--------|----------|
| 📝 | モジュールインスタンス化 | `exercises/` → `solutions/` | ⭐⭐ | 2-3時間 |
| 📝 | generate構文 | `exercises/` → `solutions/` | ⭐⭐⭐ | 3-4時間 |

## 💡 学習のヒント

### コーディングガイドライン

1. **命名規則**:
   - モジュール名: `snake_case`
   - 信号名: `snake_case`
   - 定数: `UPPER_CASE`
   - アクティブロー信号: `_n`サフィックス

2. **コメント**:
   - ファイルヘッダーに目的を記載
   - 複雑なロジックには説明を追加
   - 「なぜ」を重視（「何を」はコードから分かる）

3. **構造化**:
   - 1ファイル1モジュール（小さいヘルパーは例外）
   - 機能ごとにディレクトリ分割
   - テストベンチは対応するRTLと同じ場所

### デバッグのヒント

1. **シミュレーション**:
   - 波形を必ず確認
   - アサーションを活用
   - $display/$monitorで中間値を確認

2. **合成**:
   - 警告を無視しない
   - RTLビューアで回路図を確認
   - タイミングレポートを理解

3. **よくあるエラー**:
   - ラッチの意図しない生成 → デフォルト値を設定
   - レース条件 → ノンブロッキング代入を使用
   - ビット幅の不一致 → パラメータで管理

## 🔧 ツールとリソース

### 推奨ツール

- **エディタ**: VS Code + SystemVerilog拡張
- **シミュレータ**: 上記参照
- **波形ビューア**: GTKWave / Verdi / DVE
- **Linter**: Verilator (--lint-only)

### オンラインリソース

- [IEEE 1800-2017 SystemVerilog LRM](https://ieeexplore.ieee.org/document/8299595)
- [Verilog/SystemVerilog Guide (Doulos)](https://www.doulos.com/knowhow/)
- [ASIC World](http://www.asic-world.com/systemverilog/index.html)
- [ChipVerify](https://www.chipverify.com/systemverilog/systemverilog-tutorial)

### 参考書籍

- "SystemVerilog for Verification" - Chris Spear
- "RTL Modeling with SystemVerilog" - Stuart Sutherland
- "Digital Design and Computer Architecture" - Harris & Harris

## 🤝 貢献

この教材は学習目的で作成されています。
改善提案や追加コンテンツがあれば歓迎します。

## 📝 ライセンス

教育目的での使用を想定しています。
詳細は各ファイルのヘッダーを参照してください。

## ✅ 学習チェックリスト

### 基礎編（サンプル学習 - examples/）

- [ ] `combinational/examples/mux2x1.sv`を読んで組み合わせ回路の基本を理解
- [ ] `combinational/examples/adder.sv`でキャリー処理とオーバーフロー検出を理解
- [ ] `sequential/examples/register.sv`でレジスタの様々な実装方法を理解
- [ ] `sequential/examples/counter.sv`でカウンタのバリエーションを理解
- [ ] `fsm/examples/moore_fsm.sv`でFSMの基本パターンを理解
- [ ] ブロッキング vs ノンブロッキング代入の違いを理解
- [ ] ラッチを意図せず生成しない方法を理解

### 中級編（演習問題）

- [ ] プライオリティエンコーダを実装できる
- [ ] 乗算器を実装できる
- [ ] ALUを実装できる
- [ ] シフトレジスタを実装できる
- [ ] Mealy型FSMを実装できる
- [ ] generate構文を使いこなせる
- [ ] パラメータ化された汎用モジュールを設計できる

### 上級編（実践プロジェクト）

- [ ] UART送受信機を設計できる
- [ ] FIFOバッファを実装できる
- [ ] SPI/I2Cコントローラを実装できる
- [ ] パイプライン設計ができる
- [ ] バスプロトコル（AXI等）を実装できる
- [ ] クロックドメインクロッシングを理解
- [ ] 低消費電力設計手法を理解

## 🎓 次のステップ

基礎を習得したら、以下のトピックに進みましょう：

1. **実践プロジェクト**:
   - UART送受信機
   - SPI/I2Cコントローラ
   - 簡単なCPU設計

2. **高度な検証**:
   - UVM (Universal Verification Methodology)
   - 制約付きランダム検証
   - フォーマル検証

3. **FPGA実装**:
   - ボード実装
   - タイミングクロージャー
   - リソース最適化

---

**Happy Learning!** SystemVerilog設計の世界へようこそ。

質問や不明点があれば、各ディレクトリのREADME.mdを参照するか、
ref/ディレクトリの参考資料を確認してください。
