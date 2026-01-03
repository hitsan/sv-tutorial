// Moore型ステートマシン
// 出力は現在の状態のみに依存

/*
 * 例: シーケンス検出器 (110を検出)
 *
 * 状態遷移図:
 *
 *          0          1          1          0
 *   IDLE ----> S0 ----> S1 ----> S11 ----> DETECTED
 *    |          |        |         |          |
 *    +----[0]---+        |         |          |
 *    +---------[0]-------+         |          |
 *    +------------------[0]--------+          |
 *    +-------------------[any]----------------+
 *
 * Moore型: 出力はそれぞれの状態でのみ決まる
 * - DETECTED状態でのみ出力=1
 */

// ============================================================================
// 方法1: 1プロセスモデル（非推奨）
// ============================================================================
module moore_fsm_1process (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic detected
);
  // 状態定義（enumを使用）
  typedef enum logic [2:0] {
    IDLE     = 3'b000,
    S1       = 3'b001,  // "1"を検出
    S11      = 3'b010,  // "11"を検出
    DETECTED = 3'b011   // "110"を検出
  } state_t;

  state_t state;

  // 1つのalways_ffブロックで状態遷移と出力を記述
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      detected <= 1'b0;
    end else begin
      // デフォルト出力
      detected <= 1'b0;

      case (state)
        IDLE: begin
          if (data_in) state <= S1;
          else state <= IDLE;
        end

        S1: begin
          if (data_in) state <= S11;
          else state <= IDLE;
        end

        S11: begin
          if (!data_in) begin
            state <= DETECTED;
            // 注意: detectedは次クロックで'1'になる（レジスタ化）
          end else begin
            state <= S11;  // 連続する"1"
          end
        end

        DETECTED: begin
          detected <= 1'b1;  // この状態での出力
          // 次の検出のために状態遷移
          if (data_in) state <= S1;
          else state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

  // 問題点: detectedがレジスタ化されるため、
  // "110"検出後の次のクロックで'1'になる（1サイクル遅延）

endmodule : moore_fsm_1process


// ============================================================================
// 方法2: 2プロセスモデル（推奨）★
// ============================================================================
module moore_fsm_2process (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic detected
);
  // 状態定義
  typedef enum logic [2:0] {
    IDLE,
    S1,
    S11,
    DETECTED
  } state_t;

  state_t current_state, next_state;

  // プロセス1: 状態レジスタ（順序回路）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // プロセス2: 次状態ロジック（組み合わせ回路）
  always_comb begin
    // デフォルト値（ラッチ防止）
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (data_in) next_state = S1;
      end

      S1: begin
        if (data_in) next_state = S11;
        else next_state = IDLE;
      end

      S11: begin
        if (!data_in) next_state = DETECTED;
        // else: S11のまま（連続する"1"）
      end

      DETECTED: begin
        if (data_in) next_state = S1;
        else next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  // プロセス3: 出力ロジック（組み合わせ回路）- Moore型
  // 出力は現在の状態のみに依存
  always_comb begin
    case (current_state)
      DETECTED: detected = 1'b1;
      default:  detected = 1'b0;
    endcase
  end

  // または簡潔に:
  // assign detected = (current_state == DETECTED);

endmodule : moore_fsm_2process


// ============================================================================
// 発展例: 複数出力を持つMoore FSM
// ============================================================================
module moore_fsm_multi_output (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       done,
    output logic       busy,
    output logic       valid,
    output logic [1:0] status
);
  typedef enum logic [2:0] {
    IDLE,
    INIT,
    PROCESS,
    WAIT_DONE,
    FINISH
  } state_t;

  state_t current_state, next_state;

  // 状態レジスタ
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else current_state <= next_state;
  end

  // 次状態ロジック
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (start) next_state = INIT;
      end

      INIT: begin
        next_state = PROCESS;
      end

      PROCESS: begin
        next_state = WAIT_DONE;
      end

      WAIT_DONE: begin
        if (done) next_state = FINISH;
      end

      FINISH: begin
        next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  // 出力ロジック（Moore型 - 状態のみに依存）
  always_comb begin
    // デフォルト値
    busy   = 1'b0;
    valid  = 1'b0;
    status = 2'b00;

    case (current_state)
      IDLE: begin
        status = 2'b00;  // アイドル
      end

      INIT: begin
        busy   = 1'b1;
        status = 2'b01;  // 初期化中
      end

      PROCESS: begin
        busy   = 1'b1;
        status = 2'b10;  // 処理中
      end

      WAIT_DONE: begin
        busy   = 1'b1;
        status = 2'b10;  // 処理中
      end

      FINISH: begin
        valid  = 1'b1;
        status = 2'b11;  // 完了
      end
    endcase
  end

endmodule : moore_fsm_multi_output


// ============================================================================
// 実践例: トラフィックライトコントローラ（Moore FSM）
// ============================================================================
module traffic_light_moore (
    input  logic clk,
    input  logic rst_n,
    input  logic sensor,  // 車両検出センサー
    output logic red,
    output logic yellow,
    output logic green
);
  typedef enum logic [1:0] {
    RED,
    RED_YELLOW,  // ヨーロッパスタイル
    GREEN,
    YELLOW
  } state_t;

  state_t current_state, next_state;
  logic [3:0] timer;  // 各状態の滞在時間カウント

  // 状態レジスタ
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= RED;
    else current_state <= next_state;
  end

  // タイマー
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      timer <= '0;
    end else begin
      if (current_state != next_state) timer <= '0;  // 状態遷移時にリセット
      else timer <= timer + 1;
    end
  end

  // 次状態ロジック
  always_comb begin
    next_state = current_state;

    case (current_state)
      RED: begin
        // 5秒後、または車両検出で遷移
        if (timer >= 4'd5 || sensor) next_state = RED_YELLOW;
      end

      RED_YELLOW: begin
        // 2秒後に遷移
        if (timer >= 4'd2) next_state = GREEN;
      end

      GREEN: begin
        // 10秒後に遷移
        if (timer >= 4'd10) next_state = YELLOW;
      end

      YELLOW: begin
        // 3秒後に遷移
        if (timer >= 4'd3) next_state = RED;
      end
    endcase
  end

  // 出力ロジック（Moore型）
  always_comb begin
    {red, yellow, green} = 3'b000;

    case (current_state)
      RED:        {red, yellow, green} = 3'b100;
      RED_YELLOW: {red, yellow, green} = 3'b110;
      GREEN:      {red, yellow, green} = 3'b001;
      YELLOW:     {red, yellow, green} = 3'b010;
    endcase
  end

endmodule : traffic_light_moore


// ============================================================================
// 学習ポイントまとめ
// ============================================================================
// 1. Moore FSM: 出力は現在の状態のみに依存
// 2. 2プロセスモデル推奨:
//    - プロセス1: 状態レジスタ (always_ff)
//    - プロセス2: 次状態ロジック (always_comb)
//    - プロセス3: 出力ロジック (always_comb)
// 3. enumで状態を定義（可読性・型安全）
// 4. デフォルト値でラッチ防止
// 5. リセット時に既知の状態へ
//
// Moore型の特徴:
// - 利点: 出力が安定（グリッチなし）
// - 欠点: 出力変化が1サイクル遅れる可能性
// - 用途: 制御信号、タイミングが重要な場合
