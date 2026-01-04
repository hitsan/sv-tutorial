# 有限ステートマシン (Finite State Machine - FSM)

## はじめに

このディレクトリでは、SystemVerilogで有限ステートマシン（FSM）を作成する方法を学習します。
2つの異なるモデル、**1プロセスモデル**と**2プロセスモデル**を示します。

## FSMの基本概念

### Moore型ステートマシン
- **出力**: 現在の状態のみに依存
- **特徴**: 出力が安定（グリッチが少ない）
- **欠点**: 出力変化に1クロックサイクルの遅延

### Mealy型ステートマシン
- **出力**: 現在の状態**と入力**に依存
- **特徴**: より少ない状態で実装可能
- **欠点**: 入力変化でグリッチの可能性

## 実装モデル

### 1プロセスモデル（非推奨）
```systemverilog
// すべてを1つのalways_ffブロックで記述
always_ff @(posedge clk) begin
    // 状態遷移ロジック
    // 出力ロジック
end
```
- **問題点**: 出力が自動的にレジスタ化される（1サイクル遅延）
- **用途**: 出力を意図的に遅延させたい場合のみ

### 2プロセスモデル（推奨）★
```systemverilog
// プロセス1: 状態レジスタ（順序回路）
always_ff @(posedge clk) begin
    current_state <= next_state;
end

// プロセス2: 次状態と出力ロジック（組み合わせ回路）
always_comb begin
    next_state = ...;
    outputs = ...;
end
```
- **利点**: 出力が組み合わせ回路（遅延なし）
- **推奨**: ほとんどの場合、このモデルを使用

### 3プロセスモデル（オプション）
```systemverilog
// プロセス1: 状態レジスタ
always_ff @(posedge clk) ...

// プロセス2: 次状態ロジック
always_comb ...

// プロセス3: 出力ロジック
always_comb ...
```
- **特徴**: ロジックを分離（可読性向上）
- **注意**: 2プロセスモデルで十分な場合が多い

## 基本原則: 状態図を設計してから、コードを書く

FSMの設計では、コーディング前に以下を明確にします：
1. **状態の定義**: 必要なすべての状態
2. **遷移条件**: 状態間の遷移をトリガーする条件
3. **出力**: 各状態または遷移での出力値

状態図があれば、FSMをコードに変換するのは機械的な作業になります。

## 学習の推奨順序

### 1. Moore型ステートマシン (moore_fsm/)
- **概要**: 出力が現在の状態のみに依存する有限ステートマシンの基本実装
- **学習内容**:
  - 1プロセスモデル vs 2プロセスモデル
  - enumを使った状態定義
  - 状態遷移ロジック
  - 出力ロジック（状態のみに依存）
- **実装例**:
  - `moore_fsm_1process.sv`: 1プロセスモデル
  - `moore_fsm_2process.sv`: 2プロセスモデル（推奨）
  - `moore_fsm_multi_output.sv`: 複数出力の例
- **ファイル**: `moore_fsm/`

### 2. トラフィックライト制御 (traffic_light_moore/)
- **概要**: Moore型FSMを使った信号機制御システムの実装
- **学習内容**:
  - 実際のシステムへのMoore型FSMの適用
  - タイマーを使った状態遷移
  - 複数出力の制御（赤・黄・青信号）
- **ファイル**: `traffic_light_moore/`

### 3. エッジ検出器 (edge_detector/)
- **概要**: 入力信号の立ち上がり/立ち下がりエッジを検出する回路（Moore型とMealy型の比較）
- **学習内容**:
  - Moore型とMealy型の違いを実例で比較
  - エッジ検出ロジックの実装
  - レイテンシの違い
- **実装例**:
  - `edge_detector_moore/`: Moore型実装
  - `edge_detector_mealy/`: Mealy型実装
- **ファイル**: `edge_detector/`

### 4. パルス生成器 (pulse_generator_mealy/)
- **概要**: Mealy型FSMを使った1クロックパルス生成回路
- **学習内容**:
  - Mealy型FSMの基本実装
  - 入力に応じた即座の出力生成
  - パルス幅の制御
- **ファイル**: `pulse_generator_mealy/`

### 5. シーケンス検出器 (sequence_detector_mealy/)
- **概要**: 特定のビットパターンを検出するMealy型FSM
- **学習内容**:
  - パターンマッチング用のFSM設計
  - 重複シーケンスの処理
  - Mealy型による低レイテンシ検出
- **ファイル**: `sequence_detector_mealy/`

### 6. UART送受信制御 (uart_fsm/)
- **概要**: UART通信プロトコルの送信・受信を制御するFSM
- **学習内容**:
  - 実際の通信プロトコルのFSM実装
  - ボーレートタイミング制御
  - スタート/ストップビットの処理
  - パリティチェック
- **実装例**:
  - `uart_fsm.sv`: 統合UART FSM
  - 個別の送信・受信FSM
- **ファイル**: `uart_fsm/`

### 7. ハンドシェイクコントローラ (handshake_controller/)
- **概要**: valid/readyハンドシェイクプロトコルを制御するFSM
- **学習内容**:
  - バックプレッシャー対応の制御
  - ハンドシェイク信号の管理
  - データフロー制御
- **ファイル**: `handshake_controller/`

## 状態のエンコーディング

### Binary (バイナリ)
```systemverilog
typedef enum logic [1:0] {
    IDLE   = 2'b00,
    STATE1 = 2'b01,
    STATE2 = 2'b10,
    STATE3 = 2'b11
} state_t;
```
- **利点**: 最小のビット数（n状態で log2(n)ビット）
- **欠点**: 複雑な次状態ロジック

### One-Hot (ワンホット)
```systemverilog
typedef enum logic [3:0] {
    IDLE   = 4'b0001,
    STATE1 = 4'b0010,
    STATE2 = 4'b0100,
    STATE3 = 4'b1000
} state_t;
```
- **利点**: シンプルな次状態ロジック、高速
- **欠点**: 多くのフリップフロップ（n状態でnビット）
- **用途**: FPGA設計で推奨

### Gray Code (グレイコード)
```systemverilog
typedef enum logic [1:0] {
    IDLE   = 2'b00,
    STATE1 = 2'b01,
    STATE2 = 2'b11,
    STATE3 = 2'b10
} state_t;
```
- **利点**: 連続状態で1ビットのみ変化
- **用途**: 非同期インターフェース、低電力

## FSM設計のベストプラクティス

### 1. デフォルト状態の使用
```systemverilog
always_comb begin
    // デフォルト値を設定（ラッチ防止）
    next_state = current_state;
    output_sig = 1'b0;

    case (current_state)
        IDLE: begin
            if (start) next_state = ACTIVE;
        end
        // ...
    endcase
end
```

### 2. リセット状態の明示
```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;  // 必ず既知の状態へ
    end else begin
        current_state <= next_state;
    end
end
```

### 3. 不正状態の処理
```systemverilog
always_comb begin
    next_state = current_state;
    case (current_state)
        IDLE:    ...
        STATE1:  ...
        STATE2:  ...
        default: next_state = IDLE;  // 不正状態からの復帰
    endcase
end
```

### 4. enumの使用
```systemverilog
// 推奨: 型安全で可読性が高い
typedef enum logic [1:0] {
    IDLE, ACTIVE, DONE
} state_t;

state_t current_state, next_state;
```

### 5. 状態遷移の文書化
```systemverilog
// 状態遷移図をコメントで記載
/* State Diagram:
 *
 *    IDLE --[start]--> ACTIVE
 *      ^                  |
 *      |              [done]
 *      +--[reset]------- DONE
 */
```

## よくある間違いと対策

### 間違い1: 不完全なcase文（ラッチ生成）
```systemverilog
// 悪い例
always_comb begin
    case (current_state)
        IDLE:   next_state = STATE1;
        STATE1: next_state = STATE2;
        // STATE2の処理がない! → ラッチ
    endcase
end

// 良い例
always_comb begin
    next_state = current_state;  // デフォルト値
    case (current_state)
        IDLE:   next_state = STATE1;
        STATE1: next_state = STATE2;
        STATE2: next_state = IDLE;
    endcase
end
```

### 間違い2: 組み合わせ回路でノンブロッキング代入
```systemverilog
// 悪い例
always_comb begin
    case (current_state)
        IDLE: next_state <= STATE1;  // ノンブロッキング代入!
    endcase
end

// 良い例
always_comb begin
    case (current_state)
        IDLE: next_state = STATE1;  // ブロッキング代入
    endcase
end
```

### 間違い3: Mealy出力のグリッチ
```systemverilog
// 問題: 入力変化で出力にグリッチ
always_comb begin
    output_sig = (current_state == ACTIVE) && input_sig;
end

// 解決策1: 出力をレジスタ化
always_ff @(posedge clk) begin
    output_sig <= (next_state == ACTIVE) && input_sig;
end

// 解決策2: Moore型に変更
```

### 間違い4: リセット時の未初期化
```systemverilog
// 悪い例: リセット処理なし
always_ff @(posedge clk) begin
    current_state <= next_state;  // 初期状態が不定!
end

// 良い例: リセット処理を含める
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end
```

## デバッグのヒント

1. **状態の可視化**: シミュレーション時に状態名を表示
   ```systemverilog
   // シミュレーション専用
   `ifdef SIMULATION
   string state_name;
   always_comb begin
       case (current_state)
           IDLE:   state_name = "IDLE";
           ACTIVE: state_name = "ACTIVE";
           DONE:   state_name = "DONE";
       endcase
   end
   `endif
   ```

2. **アサーションの使用**: 不正状態の検出
   ```systemverilog
   // 不正状態の検出
   assert property (@(posedge clk)
       current_state inside {IDLE, ACTIVE, DONE})
   else $error("Invalid state detected!");
   ```

3. **カバレッジ**: すべての状態と遷移をテスト
   ```systemverilog
   covergroup state_cov @(posedge clk);
       state_cp: coverpoint current_state;
       transition_cp: coverpoint {current_state, next_state};
   endgroup
   ```

## 参考資料

- [FSM Coding Styles (Cummings)](http://www.sunburst-design.com/papers/CummingsSNUG2019SV_FSM1.pdf)
- 各ソースファイル内の詳細なコメント
