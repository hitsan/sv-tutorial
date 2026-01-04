// UDP RX - 簡易版スケルトン
module udp_rx #(
    parameter int DATA_WIDTH = 8,
    parameter logic [15:0] LOCAL_PORT = 16'd1234
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [DATA_WIDTH-1:0]  data_in,
    input  logic                   valid_in,
    output logic [15:0]            src_port,
    output logic [15:0]            dst_port,
    output logic [DATA_WIDTH-1:0]  payload_out,
    output logic                   payload_valid
);
    // TODO: UDPヘッダパーサ実装
endmodule
