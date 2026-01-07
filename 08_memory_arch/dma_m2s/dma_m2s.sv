// DMA (Memory to Stream)
// メモリからストリームへ読み出す簡易例

`timescale 1ns / 1ps
module dma_m2s #(
    parameter int ADDR_WIDTH = 16,
    parameter int DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,
    // 制御レジスタ
    input  logic [ADDR_WIDTH-1:0]  start_addr,
    input  logic [15:0]            transfer_length,
    input  logic                   start,
    output logic                   done,
    // メモリインターフェース
    output logic [ADDR_WIDTH-1:0]  mem_addr,
    output logic                   mem_read,
    input  logic [DATA_WIDTH-1:0]  mem_data,
    input  logic                   mem_valid,
    // ストリーム出力
    output logic [DATA_WIDTH-1:0]  stream_data,
    output logic                   stream_valid,
    input  logic                   stream_ready
);
    // TODO: 転送制御FSM
    // TODO: アドレス生成
endmodule
