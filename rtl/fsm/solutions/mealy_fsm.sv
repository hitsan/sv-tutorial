// Mealy型ステートマシン - 解答例

// ============================================================================
// 演習1: エッジ検出器（Mealy型）
// ============================================================================
module edge_detector_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic edge_detected
);
    typedef enum logic {
        IDLE,  // data_in=0待ち
        HIGH   // data_in=1受信後
    } state_t;

    state_t current_state, next_state;

    // 状態レジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // 次状態ロジック
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (data_in)
                    next_state = HIGH;
            end

            HIGH: begin
                if (!data_in)
                    next_state = IDLE;
            end
        endcase
    end

    // 出力ロジック（Mealy型: 状態+入力）
    always_comb begin
        edge_detected = 1'b0;

        case (current_state)
            IDLE: begin
                if (data_in)
                    edge_detected = 1'b1;  // 0→1エッジ
            end

            HIGH: begin
                edge_detected = 1'b0;
            end
        endcase
    end

endmodule : edge_detector_mealy


// ============================================================================
// 演習2: エッジ検出器（Moore型）- 比較用
// ============================================================================
module edge_detector_moore (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic edge_detected
);
    typedef enum logic [1:0] {
        IDLE,      // data_in=0待ち
        DETECTED,  // エッジ検出状態（出力=1）
        HIGH       // data_in=1保持中
    } state_t;

    state_t current_state, next_state;

    // 状態レジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // 次状態ロジック
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (data_in)
                    next_state = DETECTED;
            end

            DETECTED: begin
                if (data_in)
                    next_state = HIGH;
                else
                    next_state = IDLE;
            end

            HIGH: begin
                if (!data_in)
                    next_state = IDLE;
            end
        endcase
    end

    // 出力ロジック（Moore型: 状態のみ）
    assign edge_detected = (current_state == DETECTED);

    // 注意: Mealy型は2状態、Moore型は3状態必要

endmodule : edge_detector_moore


// ============================================================================
// 演習3: パルス生成器（Mealy型）
// ============================================================================
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

    state_t current_state, next_state;
    logic [2:0] count;

    // 状態レジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // カウンタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            if (current_state == PULSE)
                count <= count + 1;
            else
                count <= '0;
        end
    end

    // 次状態ロジック
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (start)
                    next_state = PULSE;
            end

            PULSE: begin
                if (count >= 3'd3)  // 4クロック後
                    next_state = IDLE;
            end
        endcase
    end

    // 出力ロジック（Mealy型）
    always_comb begin
        pulse = 1'b0;

        case (current_state)
            IDLE: begin
                if (start)
                    pulse = 1'b1;  // start入力と同時に出力開始
            end

            PULSE: begin
                if (count < 3'd3)
                    pulse = 1'b1;
            end
        endcase
    end

endmodule : pulse_generator_mealy


// ============================================================================
// 演習4: シーケンス検出器 "1011"（Mealy型）
// ============================================================================
module sequence_detector_mealy (
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic detected
);
    typedef enum logic [2:0] {
        IDLE,
        S1,    // "1"検出
        S10,   // "10"検出
        S101   // "101"検出
    } state_t;

    state_t current_state, next_state;

    // 状態レジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // 次状態ロジック
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (data_in)
                    next_state = S1;
            end

            S1: begin
                if (!data_in)
                    next_state = S10;
                // else: S1のまま（連続する"1"）
            end

            S10: begin
                if (data_in)
                    next_state = S101;
                else
                    next_state = IDLE;
            end

            S101: begin
                if (data_in)
                    next_state = S1;  // 検出成功、次の検出へ
                else
                    next_state = S10;
            end

            default: next_state = IDLE;
        endcase
    end

    // 出力ロジック（Mealy型: 同一サイクルで出力）
    always_comb begin
        detected = 1'b0;

        case (current_state)
            S101: begin
                if (data_in)
                    detected = 1'b1;  // "1011"検出
            end

            default: detected = 1'b0;
        endcase
    end

endmodule : sequence_detector_mealy


// ============================================================================
// 演習5: ハンドシェイクコントローラ（ハイブリッド型）
// ============================================================================
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

    state_t current_state, next_state;

    // 状態レジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // 次状態ロジック
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (start)
                    next_state = ACTIVE;
            end

            ACTIVE: begin
                if (ready)
                    next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Moore型出力: 状態のみに依存
    assign valid = (current_state == ACTIVE);

    // Mealy型出力: 状態+入力に依存
    always_comb begin
        ack = 1'b0;

        case (current_state)
            ACTIVE: begin
                if (ready)
                    ack = 1'b1;
            end

            default: ack = 1'b0;
        endcase
    end

    // または簡潔に:
    // assign ack = (current_state == ACTIVE) && ready;

endmodule : handshake_controller


// ============================================================================
// 学習ポイント
// ============================================================================
// 1. Mealy型はMoore型より少ない状態数で実装可能
//    - エッジ検出: Mealy=2状態、Moore=3状態
//
// 2. Mealy型は入力変化と同一サイクルで出力変化
//    - 高速応答が必要な場合に有利
//
// 3. Mealy型の出力ロジック:
//    - always_comb内でcurrent_stateと入力の両方を参照
//
// 4. ハイブリッド型の活用:
//    - 安定性が必要な出力: Moore型
//    - 高速応答が必要な出力: Mealy型
//
// 5. 注意点:
//    - Mealy型は入力グリッチの影響を受けやすい
//    - 必要に応じて出力をレジスタ化
