//============================================================================
// File: crc32.sv
// Description: Ethernet CRC32計算モジュール（LFSR実装）
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

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

    // TODO: 内部信号定義
    // - CRCレジスタ（LFSR）: logic [31:0] crc_reg
    // - 次のCRC値: logic [31:0] crc_next

    //========================================================================
    // TODO: CRC計算（8ビットパラレル処理）
    // 8ビット分のCRC計算をパラレルに実行
    // LFSRを使用してCRCを更新
    //========================================================================

    //========================================================================
    // TODO: CRCレジスタ更新
    // sof時にリセット、valid_in時に更新
    //========================================================================

    //========================================================================
    // TODO: CRC出力
    // eof時にCRCを出力（Final XOR: ビット反転）
    //========================================================================

endmodule
