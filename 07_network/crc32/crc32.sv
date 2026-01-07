// CRC32 計算モジュール
// Ethernet CRC32 を LFSR で計算

`timescale 1ns / 1ps

module crc32 #(
    parameter logic [31:0] POLYNOMIAL = 32'h04C11DB7  // Ethernet CRC32多項式
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [7:0]  data_in,
    input  logic        valid_in,
    input  logic        sof,         // Start of Frame
    input  logic        eof,         // End of Frame
    output logic [31:0] crc_out,
    output logic        crc_valid
);

    // TODO: CRCレジスタ

    // TODO: 8ビット入力に対するCRC計算

    // TODO: フレーム境界でのレジスタ制御

    // TODO: CRC出力

endmodule
