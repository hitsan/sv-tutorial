// UART送受信コントローラ - 解答例

// ============================================================================
// 演習1: UART送信機
// ============================================================================
module uart_tx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy,
    output logic       tx_done
);
    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t current_state, next_state;

    logic [7:0] data_reg;    // 送信データレジスタ
    logic [2:0] bit_count;   // ビットカウンタ (0-7)
    logic [3:0] baud_count;  // ボーレートカウンタ (0-15)
    logic       baud_tick;   // ボーレートクロック

    // 状態レジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // ボーレートカウンタ (16分周)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_count <= '0;
        end else begin
            if (current_state == IDLE)
                baud_count <= '0;
            else
                baud_count <= baud_count + 1;
        end
    end

    assign baud_tick = (baud_count == 4'd15);

    // データレジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= '0;
        end else begin
            if (tx_start && current_state == IDLE)
                data_reg <= tx_data;
            else if (baud_tick && current_state == DATA)
                data_reg <= {1'b0, data_reg[7:1]};  // 右シフト（LSBファースト）
        end
    end

    // ビットカウンタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_count <= '0;
        end else begin
            if (current_state != DATA)
                bit_count <= '0;
            else if (baud_tick)
                bit_count <= bit_count + 1;
        end
    end

    // 次状態ロジック
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (tx_start)
                    next_state = START;
            end

            START: begin
                if (baud_tick)
                    next_state = DATA;
            end

            DATA: begin
                if (baud_tick && bit_count == 3'd7)
                    next_state = STOP;
            end

            STOP: begin
                if (baud_tick)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // 出力ロジック
    always_comb begin
        case (current_state)
            IDLE:  tx = 1'b1;           // アイドル = HIGH
            START: tx = 1'b0;           // スタートビット = LOW
            DATA:  tx = data_reg[0];    // データビット（LSBファースト）
            STOP:  tx = 1'b1;           // ストップビット = HIGH
            default: tx = 1'b1;
        endcase
    end

    assign tx_busy = (current_state != IDLE);
    assign tx_done = (current_state == STOP) && baud_tick;

endmodule : uart_tx


// ============================================================================
// 演習2: UART受信機
// ============================================================================
module uart_rx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       rx_error
);
    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t current_state, next_state;

    logic [7:0] data_reg;
    logic [2:0] bit_count;
    logic [3:0] baud_count;
    logic       baud_tick;

    // rx入力の同期化（メタステーブル防止）
    logic [1:0] rx_sync;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rx_sync <= 2'b11;
        else
            rx_sync <= {rx_sync[0], rx};
    end

    logic rx_stable;
    assign rx_stable = rx_sync[1];

    // 状態レジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // ボーレートカウンタ（16分周、中央でサンプリング）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_count <= '0;
        end else begin
            if (current_state == IDLE)
                baud_count <= '0;
            else
                baud_count <= baud_count + 1;
        end
    end

    // ビット中央でサンプリング
    assign baud_tick = (baud_count == 4'd7);

    // ビットカウンタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_count <= '0;
        end else begin
            if (current_state != DATA)
                bit_count <= '0;
            else if (baud_tick)
                bit_count <= bit_count + 1;
        end
    end

    // データレジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= '0;
        end else begin
            if (baud_tick && current_state == DATA)
                data_reg <= {rx_stable, data_reg[7:1]};  // 右シフト（LSBファースト）
        end
    end

    // 次状態ロジック
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (!rx_stable)  // スタートビット検出（0）
                    next_state = START;
            end

            START: begin
                if (baud_tick) begin
                    if (!rx_stable)
                        next_state = DATA;
                    else
                        next_state = IDLE;  // ノイズ検出
                end
            end

            DATA: begin
                if (baud_tick && bit_count == 3'd7)
                    next_state = STOP;
            end

            STOP: begin
                if (baud_tick)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // 受信データ出力
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data <= '0;
        end else begin
            if (current_state == STOP && baud_tick)
                rx_data <= data_reg;
        end
    end

    // 出力信号
    assign rx_valid = (current_state == STOP) && baud_tick && rx_stable;
    assign rx_error = (current_state == STOP) && baud_tick && !rx_stable;  // ストップビット異常

endmodule : uart_rx


// ============================================================================
// 演習3: UART送受信統合モジュール
// ============================================================================
module uart (
    input  logic       clk,
    input  logic       rst_n,
    // 送信側
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy,
    output logic       tx_done,
    // 受信側
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       rx_error
);
    // 送信機インスタンス
    uart_tx u_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done)
    );

    // 受信機インスタンス
    uart_rx u_rx (
        .clk      (clk),
        .rst_n    (rst_n),
        .rx       (rx),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .rx_error (rx_error)
    );

endmodule : uart


// ============================================================================
// 学習ポイント
// ============================================================================
// 1. 実践的なFSMはカウンタやレジスタと組み合わせる
//    - ボーレートカウンタ
//    - ビットカウンタ
//    - データシフトレジスタ
//
// 2. 非同期入力の同期化
//    - rx入力を2段FFで同期化（メタステーブル防止）
//
// 3. ビット中央でのサンプリング
//    - 受信側: baud_count=7（中央）でサンプリング
//    - 送信側: baud_count=15（終端）で次ビットへ
//
// 4. エラーハンドリング
//    - スタートビットの再確認（ノイズ対策）
//    - ストップビット異常検出
//
// 5. 状態遷移の明確化
//    - IDLE → START → DATA(8回) → STOP → IDLE
//    - 各状態での処理を明確に分離
