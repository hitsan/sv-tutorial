// UDP RX (受信)
// UDPヘッダ解析とペイロード抽出
// すべてのUDPパケットを解析し、ポート情報とペイロードを出力

`timescale 1ns / 1ps
module udp_rx #(
    parameter int DATA_WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  valid_in,
    output logic [          15:0] src_port,
    output logic [          15:0] dst_port,
    output logic [DATA_WIDTH-1:0] payload_out,
    output logic                  payload_valid
);

  // TODO: UDPヘッダパーサ実装
  //
  // 実装ガイド:
  // 1. ステートマシンの設計
  //    - UDPヘッダは以下の順序で8バイト:
  //      Source Port(2) → Dest Port(2) → Length(2) → Checksum(2)
  //    - 各フィールドをパースするステートを定義
  //    - ビッグエンディアン（上位バイトが先）に注意
  //

  typedef enum {
    IDLE,
    SRC_PORT_H,
    SRC_PORT_L,
    DST_PORT_H,
    DST_PORT_L,
    LENGTH_H,
    LENGTH_L,
    CHECKSUM_H,
    CHECKSUM_L,
    PAYLOAD
  } state_t;

  state_t current;
  state_t next;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current <= IDLE;
    else current <= next;
  end

  always_comb begin
    case (current)
      IDLE: if (valid_in) next = SRC_PORT_H;
      SRC_PORT_H: next = valid_in ? IDLE : SRC_PORT_L;
      SRC_PORT_L: next = valid_in ? IDLE : DST_PORT_H;
      DST_PORT_H: next = valid_in ? IDLE : DST_PORT_H;
      DST_PORT_L: next = valid_in ? IDLE : LENGTH_H;
      LENGTH_H: next = valid_in ? IDLE : LENGTH_L;
      LENGTH_L: next = valid_in ? IDLE : CHECKSUM_H;
      CHECKSUM_H: next = valid_in ? IDLE : CHECKSUM_L;
      CHECKSUM_L: next = valid_in ? IDLE : PAYLOAD;
      PAYLOAD: begin
        if (payload_count > length - 7) next = IDLE;
        else next = PAYLOAD;
      end
      default: ;
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) src_port <= '0;
    else begin
      case (current)
        SRC_PORT_H, SRC_PORT_L: src_port <= {src_port[7:0], data_in};
        default: src_port <= src_port;
      endcase
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) dst_port <= '0;
    else begin
      case (current)
        DST_PORT_H, DST_PORT_L: dst_port <= {dst_port[7:0], data_in};
        default: dst_port <= dst_port;
      endcase
    end
  end

  // 2. Lengthフィールドの処理（重要）
  //    - UDP Lengthフィールド = ヘッダ(8) + ペイロード長
  //    - ペイロード長 = Length - 8
  //    - Lengthで指定された分だけペイロードを出力
  //    - それ以上のデータは破棄する

  logic [15:0] length;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) length <= '0;
    else begin
      case (current)
        IDLE: length <= '0;
        LENGTH_H, LENGTH_L: length <= {length[7:0], data_in};
        default: length <= length;
      endcase
    end
  end

  // 3. ペイロード出力制御
  //    - payload_countカウンタを用意
  //    - payload_count < (Length - 8) の間だけpayload_valid=1
  //    - Lengthに達したらIDLEへ遷移（valid_in=1でも終了）
  //
  logic [15:0] payload_count;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) payload_count <= '0;
    else begin
      case (current)
        IDLE: payload_count <= '0;
        PAYLOAD: begin
          if (valid_in) payload_count <= payload_count + 1;
          else payload_count <= payload_count;
        end
        default: ;
      endcase
    end
  end

  assign payload_valid = (current == PAYLOAD && payload_count < length - 8);

  always_comb begin
    payload_out = payload_valid ? data_in : '0;
  end

  // 4. エラー処理
  //    - ヘッダ受信中にvalid_in=0 → IDLEへ戻る
  //    - ペイロード受信中のvalid_in=0は一時停止として扱う
  //
  // 5. チェックサム
  //    - 簡易版のため検証不要（読み捨て）
  //

endmodule
