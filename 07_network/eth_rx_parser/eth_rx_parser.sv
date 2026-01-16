// Ethernet RX パーサ
// WHY: 学習用にEthernetフレームの基本構造を観察・確認できる最小構成を提供する。
// WHAT: 8-bit入力からpreamble/SFDを検出し、DA/SA/EtherTypeを抽出して
//       ペイロードをストリーム出力する（フレーム中は連続前提）。
// 仕様（要約）:
// - 8-bit入力、preamble(7x0x55)+SFD(0xD5)は連続必須
// - SFD以降: DA(6) -> SA(6) -> EtherType(2) -> payload
// - フレーム終端はvalid_inの低下で判定
// - フレーム中はvalid連続を前提（ギャップはIFGのみ）
// - frame_errでSFD不一致/短小フレーム/途中切断を通知
// - VLAN/FCSは未対応

`timescale 1ns / 1ps

module eth_rx_parser #(
    parameter int DATA_WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  valid_in,
    output logic [          47:0] dst_mac,
    output logic [          47:0] src_mac,
    output logic [          15:0] ether_type,
    output logic [DATA_WIDTH-1:0] payload_out,
    output logic                  payload_valid,
    output logic                  frame_err
);
  // 定数定義
  localparam [3:0] PREAMBLE_BYTES = 7;
  localparam [3:0] MAC_BYTES = 6;
  localparam [3:0] ETYPE_BYTES = 2;

  // 状態: IDLE, PREAMBLE, DA, SA, TYPE, PAYLOAD, DROP
  typedef enum logic [2:0] {
    IDLE,
    PREAMBLE,
    DA,
    SA,
    TYPE,
    PAYLOAD,
    DROP
  } state_t;
  state_t current;
  state_t next;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current <= IDLE;
    else current <= next;
  end

  logic [3:0] byte_cnt;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || next != current) byte_cnt <= '0;
    else if (valid_in) begin
      case (current)
        PREAMBLE: if (data_in == 8'h55) byte_cnt <= byte_cnt + 1;
        DA, SA, TYPE: byte_cnt <= byte_cnt + 1;
        default: ;
      endcase
    end
  end

  always_comb begin
    next = current;
    case (current)
      IDLE: begin
        if (valid_in & data_in == 8'h55) next = PREAMBLE;
      end
      PREAMBLE: begin
        if (!valid_in) next = DROP;
        else if (data_in == 8'h55) next = PREAMBLE;
        else if (byte_cnt >= PREAMBLE_BYTES - 1 && data_in == 8'hD5) next = DA;
        else next = DROP;
      end
      DA: begin
        if (!valid_in) next = DROP;
        else if (byte_cnt >= MAC_BYTES - 1) next = SA;
      end
      SA: begin
        if (!valid_in) next = DROP;
        else if (byte_cnt >= MAC_BYTES - 1) next = TYPE;
      end
      TYPE: begin
        if (!valid_in) next = DROP;
        else if (byte_cnt >= ETYPE_BYTES - 1) next = PAYLOAD;
      end
      PAYLOAD: if (!valid_in) next = IDLE;
      DROP: if (!valid_in) next = IDLE;
      default: next = IDLE;
    endcase
  end

  logic [47:0] dst_reg;
  logic [47:0] src_reg;
  logic [15:0] ether_type_reg;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dst_reg <= '0;
      src_reg <= '0;
      ether_type_reg <= '0;
      payload_out <= '0;
    end else begin
      case (current)
        IDLE, DROP: payload_out <= '0;
        PREAMBLE: begin
          dst_reg <= '0;
          src_reg <= '0;
          ether_type_reg <= '0;
        end
        DA: begin
          if (valid_in) dst_reg <= {dst_reg[39:0], data_in};
        end
        SA: begin
          if (valid_in) src_reg <= {src_reg[39:0], data_in};
        end
        TYPE: begin
          if (valid_in) begin
            ether_type_reg <= {ether_type_reg[7:0], data_in};
          end
        end
        PAYLOAD: begin
          if (valid_in) payload_out <= data_in;
        end
        default: ;
      endcase
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) payload_valid <= 0;
    else if (current == PAYLOAD) payload_valid <= valid_in;
    else payload_valid <= 0;
  end

  assign frame_err = (next == DROP);
  assign dst_mac = dst_reg;
  assign src_mac = src_reg;
  assign ether_type = ether_type_reg;

endmodule
