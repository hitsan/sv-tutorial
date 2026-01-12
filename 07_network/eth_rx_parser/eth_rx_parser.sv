// Ethernet RX パーサ
// WHY: 学習用にEthernetフレームの基本構造を観察・確認できる最小構成を提供する。
// WHAT: 8-bit入力からpreamble/SFDを検出し、DA/SA/EtherTypeを抽出して
//       ペイロードをストリーム出力する（ギャップ制約あり）。
// 仕様（要約）:
// - 8-bit入力、preamble(7x0x55)+SFD(0xD5)は連続必須
// - SFD以降: DA(6) -> SA(6) -> EtherType(2) -> payload
// - フレーム終端はvalid_inの低下で判定
// - ペイロード中のみvalidギャップを許容（最大4サイクル連続）
// - frame_errでSFD不一致/ギャップ超過/短小フレームを通知
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
    output logic                  payload_valid
);
  // TODO: FSMベースのEthernetパーサ実装
  // 状態: IDLE, PREAMBLE, DA, SA, TYPE, PAYLOAD
  typedef enum logic [2:0] {
    IDLE,
    PREAMBLE,
    DA,
    SA,
    TYPE,
    PAYLOAD
  } state_t;
  state_t current;
  state_t next;
  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) current <= IDLE;
    else current <= next;
  end

  logic [2:0] byte_cnt;
  logic [2:0] gap_cnt;
  always_ff @(posedge clk or negedge rst_n) begin
    case (next)
      IDLE: begin
        byte_cnt <= '0;
        if (valid_in & data_in == 8'h55) begin
          next = PREAMBLE;
        end
      end
      PREAMBLE: begin
        if (data_in == 8'h55) byte_cnt <= byte_cnt + 1;
        else if (byte_cnt >= 6 & data_in == 8'hD5) begin
          byte_cnt <= '0;
          next <= DA;
        end else if (!valid_in) begin
          byte_cnt <= '0;
          next = IDLE;
        end
      end
      DA: begin
        if (byte_cnt >= 5) begin
          byte_cnt <= '0;
          next <= SA;
        end else begin
          byte_cnt <= byte_cnt + 1;
        end
      end
      SA: begin
        if (byte_cnt >= 5) begin
          byte_cnt <= '0;
          next <= TYPE;
        end else begin
          byte_cnt <= byte_cnt + 1;
        end
      end
      TYPE: begin
        if (byte_cnt >= 1) begin
          byte_cnt <= '0;
          next <= PAYLOAD;
        end else begin
          byte_cnt <= byte_cnt + 1;
        end
      end
      PAYLOAD: begin
        if (valid_in) begin
          payload_out <= data_in;
          payload_valid <= 1;
          byte_cnt <= byte_cnt + 1;
          gap_cnt <= '0;
        end else if (!valid_in) begin
          if (gap_cnt > 4) begin
            if (byte_cnt >= 4) begin
              next <= IDLE;
              byte_cnt <= '0;
              gap_cnt <= '0;
            end else begin
              next <= IDLE;
              byte_cnt <= '0;
              gap_cnt <= '0;
            end
          end else begin
            gap_cnt <= gap_cnt + 1;
          end
        end
      end
      default: begin
        byte_cnt <= '0;
        next <= IDLE;
      end
    endcase
  end

  logic [47:0] dst_reg;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) dst_reg <= '0;
    else if (next == DA) begin
      dst_reg <= {dst_reg[39:0], data_in};
    end
  end
  assign dst_mac = dst_reg;

  logic [47:0] src_reg;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) src_reg <= '0;
    else if (next == SA) begin
      src_reg <= {src_reg[39:0], data_in};
    end
  end
  assign src_mac = src_reg;

  logic [15:0] ether_type_reg;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) ether_type_reg <= '0;
    else if (next == TYPE) begin
      ether_type_reg <= {ether_type_reg[7:0], data_in};
    end
  end
  assign ether_type = ether_type_reg;


endmodule
