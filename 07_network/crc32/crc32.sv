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
  logic [31:0] crc_reg;
  logic [31:0] crc_next;
  always_comb begin
    crc_next = crc_reg;
    if (valid_in) begin
      crc_next = calc_crc(sof ? 32'hFFFFFFFF : crc_reg, data_in);
    end else if (sof) crc_next = 32'hFFFF_FFFF;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc_reg <= 32'hFFFF_FFFF;
    else crc_reg <= crc_next;
  end

  assign crc_out = crc_reg ^ 32'hFFFF_FFFF;

  function automatic logic [31:0] calc_crc(logic [31:0] crc, logic [7:0] data);
    logic [31:0] next_crc;

    next_crc = crc ^ {24'b0, data};
    for (int i = 0; i < 8; i++) begin
      if (next_crc[0]) next_crc = (next_crc >> 1) ^ POLYNOMIAL;
      else next_crc = next_crc >> 1;
    end
    return next_crc;
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc_valid <= 0;
    else crc_valid <= eof;
  end
endmodule
