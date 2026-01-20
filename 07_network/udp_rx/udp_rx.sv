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

  // 2. Lengthフィールドの処理（重要）
  //    - UDP Lengthフィールド = ヘッダ(8) + ペイロード長
  //    - ペイロード長 = Length - 8
  //    - Lengthで指定された分だけペイロードを出力
  //    - それ以上のデータは破棄する
  logic [15:0] length;

  // 3. ペイロード出力制御
  //    - payload_countカウンタを用意
  //    - payload_count < (Length - 8) の間だけpayload_valid=1
  //    - Lengthに達したらIDLEへ遷移（valid_in=1でも終了）
  logic [15:0] payload_count;
  logic [15:0] payload_len;

  always_comb begin
    payload_len = (length >= 16'd8) ? (length - 16'd8) : 16'd0;
  end

  // 1-process style: 状態遷移とデータキャプチャを統合
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current <= IDLE;
      src_port <= '0;
      dst_port <= '0;
      length <= '0;
      payload_count <= '0;
    end else begin
      case (current)
        IDLE: begin
          if (valid_in) begin
            current <= SRC_PORT_H;
            src_port[15:8] <= data_in;
          end
          length <= '0;
          payload_count <= '0;
        end

        SRC_PORT_H: begin
          if (valid_in) begin
            current <= SRC_PORT_L;
            src_port[7:0] <= data_in;
          end else begin
            current <= IDLE;
          end
        end

        SRC_PORT_L: begin
          if (valid_in) begin
            current <= DST_PORT_H;
            dst_port[15:8] <= data_in;
          end else begin
            current <= IDLE;
          end
        end

        DST_PORT_H: begin
          if (valid_in) begin
            current <= DST_PORT_L;
            dst_port[7:0] <= data_in;
          end else begin
            current <= IDLE;
          end
        end

        DST_PORT_L: begin
          if (valid_in) begin
            current <= LENGTH_H;
            length[15:8] <= data_in;
          end else begin
            current <= IDLE;
          end
        end

        LENGTH_H: begin
          if (valid_in) begin
            current <= LENGTH_L;
            length[7:0] <= data_in;
          end else begin
            current <= IDLE;
          end
        end

        LENGTH_L: begin
          if (valid_in) begin
            current <= CHECKSUM_H;
          end else begin
            current <= IDLE;
          end
        end

        CHECKSUM_H: begin
          if (valid_in) begin
            current <= CHECKSUM_L;
          end else begin
            current <= IDLE;
          end
        end

        CHECKSUM_L: begin
          if (valid_in) begin
            current <= PAYLOAD;
          end else begin
            current <= IDLE;
          end
        end

        PAYLOAD: begin
          if (payload_len == 0 || payload_count >= payload_len - 1) begin
            current <= IDLE;
            payload_count <= '0;
          end else begin
            if (valid_in) begin
              payload_count <= payload_count + 1;
            end
            // valid_in=0の時は一時停止（カウント維持、状態維持）
          end
        end

        default: begin
          current <= IDLE;
        end
      endcase
    end
  end

  assign payload_valid = (current == PAYLOAD && payload_count < payload_len && valid_in);

  assign payload_out   = payload_valid ? data_in : '0;

  // 4. エラー処理
  //    - ヘッダ受信中にvalid_in=0 → IDLEへ戻る
  //    - ペイロード受信中のvalid_in=0は一時停止として扱う
  //
  // 5. チェックサム
  //    - 簡易版のため検証不要（読み捨て）
  //

endmodule
