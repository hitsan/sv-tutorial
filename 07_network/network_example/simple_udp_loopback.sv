// UDP Loopback Example - 簡易版スケルトン
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
