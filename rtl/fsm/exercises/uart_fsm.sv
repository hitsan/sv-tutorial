// UART送受信コントローラ - 演習問題
// 実践的なFSMの例

/*
 * UART (Universal Asynchronous Receiver/Transmitter)
 *
 * フォーマット: 1スタートビット + 8データビット + 1ストップビット
 *
 *   IDLE  START   D0    D1    D2  ...  D7   STOP  IDLE
 *    1  |  0   |  x  |  x  |  x  | ... | x  |  1  |  1
 */

// ============================================================================
// 演習1: UART送信機
// ============================================================================
/*
 * 要求仕様:
 * - tx_start パルスで送信開始
 * - tx_data[7:0] を LSBファーストで送信
 * - ボーレート: CLK / 16 （16分周）
 * - 送信中は tx_busy = 1
 * - 送信完了で tx_done パルス
 *
 * 状態遷移:
 *   IDLE → START → DATA0 → ... → DATA7 → STOP → IDLE
 */
module uart_tx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy,
    output logic       tx_done
);
    // ここに実装
endmodule : uart_tx


// ============================================================================
// 演習2: UART受信機
// ============================================================================
/*
 * 要求仕様:
 * - rx入力を監視してスタートビット（0）を検出
 * - 8ビットデータを受信（LSBファースト）
 * - 受信完了で rx_valid = 1（1サイクル）
 * - rx_data[7:0] に受信データを出力
 * - エラー検出（ストップビット != 1）
 *
 * 状態遷移:
 *   IDLE → START → DATA0 → ... → DATA7 → STOP → IDLE
 */
module uart_rx (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       rx_error
);
    // ここに実装
endmodule : uart_rx


// ============================================================================
// 演習3: UART送受信統合モジュール（発展課題）
// ============================================================================
/*
 * 要求仕様:
 * - 上記の送信機と受信機を統合
 * - 双方向通信をサポート
 */
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
    // ここに実装
endmodule : uart
