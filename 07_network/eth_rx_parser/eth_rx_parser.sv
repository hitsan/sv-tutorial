// Ethernet RX Parser - 簡易版スケルトン
// 詳細な実装は学習者が追加可能

module eth_rx_parser #(
    parameter int DATA_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [DATA_WIDTH-1:0]  data_in,
    input  logic                   valid_in,
    output logic [47:0]            dst_mac,
    output logic [47:0]            src_mac,
    output logic [15:0]            ether_type,
    output logic [DATA_WIDTH-1:0]  payload_out,
    output logic                   payload_valid
);
    // TODO: FSMベースのEthernetパーサ実装
    // 状態: IDLE, PREAMBLE, DA, SA, TYPE, PAYLOAD
endmodule
