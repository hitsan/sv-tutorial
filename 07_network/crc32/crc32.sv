// CRC32 計算モジュール
// Ethernet CRC32 を LFSR で計算
// ISO-HDLC (CRC-32) / IEEE 802.3 準拠

`timescale 1ns / 1ps

module crc32 #(
    parameter logic [31:0] POLYNOMIAL = 32'hEDB88320  // Ethernet CRC32多項式 (LSBファースト、ISO-HDLC)
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 7:0] data_in,
    input  logic        valid_in,
    input  logic        sof,       // Start of Frame
    input  logic        eof,       // End of Frame
    output logic [31:0] crc_out,
    output logic        crc_valid
);

  // TODO: CRCレジスタ
  logic [31:0] crc_reg;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc_reg <= 32'hFFFF_FFFF;
    else if (valid_in & sof) begin
      crc_reg <= calc_crc(32'hFFFF_FFFF, data_in);
    end else if (sof) begin
      crc_reg <= 32'hFFFF_FFFF;
    end else if (valid_in) begin
      crc_reg <= calc_crc(crc_reg, data_in);
    end
  end
  assign crc_out = crc_reg ^ 32'hFFFF_FFFF;
  // TODO: 8ビット入力に対するCRC計算
  function automatic logic [31:0] calc_crc(logic [31:0] crc, logic [7:0] data);
    logic [31:0] next_crc;

    next_crc = crc ^ {24'b0, data};
    for (int i = 0; i < 8; i++) begin
      if (next_crc[0]) begin
        next_crc = (next_crc >> 1) ^ POLYNOMIAL;
      end else begin
        next_crc = next_crc >> 1;
      end
    end
    return next_crc;
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc_valid <= 0;
    end else begin
      crc_valid <= eof;
    end
  end
endmodule
