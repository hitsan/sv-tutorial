// UDP ループバック例
// 受信ペイロードを送信側へ折り返す

`timescale 1ns / 1ps
module simple_udp_loopback (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] rx_data,
    input  logic       rx_valid,
    output logic [7:0] tx_data,
    output logic       tx_valid
);
    // TODO: 統合実装
    // eth_rx_parser + udp_rx + udp_tx の接続
endmodule
