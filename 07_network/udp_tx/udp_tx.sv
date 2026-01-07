// UDP TX (送信)
// UDPヘッダ生成とペイロード出力

`timescale 1ns / 1ps
module udp_tx #(
    parameter int DATA_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [15:0]            src_port,
    input  logic [15:0]            dst_port,
    input  logic [DATA_WIDTH-1:0]  payload_in,
    input  logic                   payload_valid,
    output logic [DATA_WIDTH-1:0]  packet_out,
    output logic                   packet_valid
);
    // TODO: UDPパケット生成実装
endmodule
