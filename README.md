# SystemVerilog 学習教材

SystemVerilogによるRTL設計と検証を体系的に学習するための教材です。
基礎から応用まで、実践的なサンプルコードと詳細な解説を提供します。

## コンテンツ

### 1. 組み合わせ回路 (Combinational Logic)
**ディレクトリ**: `01_combinational/`

基本的な論理回路の記述方法を学習します。

- **学習トピック**:
  - 2:1マルチプレクサ
  - 4入力プライオリティエンコーダ
  - パラメータ化プライオリティエンコーダ
  - 加算器
  - 乗算器
  - ALU

- **詳細**: `01_combinational/README.md`

### 2. 順序回路 (Sequential Logic)
**ディレクトリ**: `02_sequential/`

クロック同期回路とレジスタの記述を学習します。

- **学習トピック**:
  - レジスタ（非同期/同期リセット、イネーブル）
  - 順序回路の合成例
  - カウンタ（アップ/ダウン、BCD、グレイコード等）
  - シフトレジスタ
  - パイプライン化された乗算器

- **詳細**: `02_sequential/README.md`

### 3. 有限ステートマシン (FSM)
**ディレクトリ**: `03_fsm/`

制御ロジックの中核となるFSMを学習します。

- **学習トピック**:
  - Moore型ステートマシン
  - トラフィックライト制御
  - エッジ検出器（Moore型とMealy型の比較）
  - パルス生成器
  - シーケンス検出器
  - UART送受信制御
  - ハンドシェイクコントローラ

- **詳細**: `03_fsm/README.md`

### 4. 構造記述 (Structural Description)
**ディレクトリ**: `04_structural/`

モジュールの階層化と再利用を学習します。

- **学習トピック**:
  - モジュールインスタンス化
  - generate構文
  - パラメータ化設計

- **詳細**: `04_structural/README.md`

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
MIT

