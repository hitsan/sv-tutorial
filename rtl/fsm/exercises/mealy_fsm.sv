// Mealy型ステートマシン - 演習問題
// 出力は現在の状態**と入力**に依存

/*
 * Mealy型 vs Moore型の違い:
 * - Moore型: 出力 = f(現在の状態)
 * - Mealy型: 出力 = f(現在の状態, 入力)
 */

// ============================================================================
// 演習1: エッジ検出器（Mealy型）
// ============================================================================
/*
 * 要求仕様:
 * - 入力が 0→1 に変化したサイクルで edge_detected = 1
 * - その他の場合は edge_detected = 0
 * - 2状態で実装可能（Moore型は3状態必要）
 */
module edge_detector_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic edge_detected
);
  typedef enum logic {
    IDLE = 1'b0,
    HIGH = 1'b1
  } state_t;

  state_t current_state;
  state_t next_state;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE: if (data_in) next_state = HIGH;
      HIGH: if (!data_in) next_state = IDLE;
    endcase
  end

  always_comb begin
    edge_detected = 1'b0;
    case (current_state)
      IDLE: if (data_in) edge_detected = 1'b1;
      HIGH: edge_detected = 1'b0;
    endcase
  end
endmodule : edge_detector_mealy


// ============================================================================
// 演習2: 同じエッジ検出器をMoore型で実装（比較用）
// ============================================================================
/*
 * 要求仕様:
 * - 上記と同じ機能をMoore型で実装
 * - 出力は次サイクルになることに注意
 */
module edge_detector_moore (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic edge_detected
);
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    DETECTED = 2'b01,
    HIGH = 2'b10
  } state_t;

  state_t current_state;
  state_t next_state;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE: if (data_in) next_state = DETECTED;
      DETECTED: begin
        if (data_in) next_state = HIGH;
        else next_state = IDLE;
      end
      HIGH: if (!data_in) next_state = IDLE;
    endcase
  end
  assign edge_detected = (current_state == DETECTED);

endmodule : edge_detector_moore


// ============================================================================
// 演習3: パルス生成器（Mealy型）
// ============================================================================
/*
 * 要求仕様:
 * - startパルスで4クロック幅のパルスを生成
 * - start入力と同じサイクルからpulse出力開始
 */
module pulse_generator_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic pulse
);
  typedef enum logic {
    IDLE,
    PULSE
  } state_t;

  state_t state_c;
  state_t state_n;
  logic [2:0] count;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_c <= IDLE;
    else state_c <= state_n;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= 0;
    else
      if (state_c == PULSE) count <= count + 1;
      else count <= 0;
  end

  always_comb begin
    state_n = state_c;
    case (state_c)
      IDLE: if (start) state_n = PULSE;
      PULSE: begin
        if (count > 4) begin
          state_n = IDLE;
        end
      end
    endcase
  end

  always_comb begin
    pulse = 1'b0;
    case (state_c)
      IDLE: begin
        if (start) pulse = 1'b1;
      end
      PULSE: begin
        if (count < 4) pulse = 1'b1;
      end
    endcase
  end

endmodule : pulse_generator_mealy


// ============================================================================
// 演習4: シーケンス検出器 "1011"（Mealy型）
// ============================================================================
/*
 * 要求仕様:
 * - "1011"パターンを検出
 * - 最後のビット入力と同時に出力=1（同一サイクル）
 */
module sequence_detector_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic detected
);
  typedef enum logic [2:0] {
    IDLE = 3'b000,
    S1 = 3'b001,
    S10 = 3'b010,
    S101 = 3'b101
  } pattern_t;
  pattern_t state_c;
  pattern_t state_n;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_c <= IDLE;
    else state_c <= state_n;
  end

  always_comb begin
    state_n = state_c;
    case (state_c)
      IDLE: if (data_in) state_n = S1;
      S1: if (!data_in) state_n = S10;
      S10: begin
        if (data_in) state_n = S101;
        else state_n = IDLE;
      end
      S101:  begin
        if (data_in) state_n = S1;
        else state_n = S10;
      end
      default: state_n = IDLE;
    endcase
  end

  assign detected = (state_c == S101) & data_in;

  endmodule : sequence_detector_mealy


// ============================================================================
// 演習5: ハンドシェイクコントローラ（ハイブリッド型）
// ============================================================================
/*
 * 要求仕様:
 * - valid: Moore型出力（ACTIVE状態で=1）
 * - ack: Mealy型出力（ACTIVE状態 && ready=1で=1）
 */
module handshake_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic ready,
    output logic valid,
    output logic ack
);
  typedef enum logic [1:0] {
    IDLE,
    ACTIVE,
    DONE
  } state_t;
  state_t state_c;
  state_t state_n;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_c <= IDLE;
    else state_c <= state_n;
  end

  always_comb begin
    state_n = state_c;
    case (state_c)
      IDLE: if (start) state_n = ACTIVE;
      ACTIVE: if (ready) state_n = DONE;
      DONE: state_n = IDLE;
      default: state_n = IDLE;
    endcase
  end

  always_comb begin
    ack = 1'b0;
    case (state_c)
      ACTIVE: if (ready) ack = 1'b1;
      default: ack = 1'b0;
    endcase
  end

  assign valid = (state_c == ACTIVE);
endmodule : handshake_controller
