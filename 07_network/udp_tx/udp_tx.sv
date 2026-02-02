// UDP TX (送信)
// UDPヘッダ生成とペイロード出力

`timescale 1ns / 1ps
module udp_tx #(
    parameter int DATA_WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,
    // ペイロード入力
    input  logic [          15:0] src_port,
    input  logic [          15:0] dst_port,
    input  logic [          31:0] src_ip,             // チェックサム計算用
    input  logic [          31:0] dst_ip,             // チェックサム計算用
`ifdef UDP_TX_HAS_LEN
    input  logic [          15:0] payload_len,        // バイト数(0も可)
    input  logic                  payload_len_valid,
`endif
    input  logic [DATA_WIDTH-1:0] payload_in,
    input  logic                  payload_valid,
    input  logic                  payload_sof,        // Start of Frame
    input  logic                  payload_eof,        // End of Frame
    output logic                  payload_ready,      // バックプレッシャー
    // パケット出力
    output logic [DATA_WIDTH-1:0] packet_out,
    output logic                  packet_valid,
    output logic                  packet_sof,
    output logic                  packet_eof
);

  // ====================================================================
  // 実装ヒント
  // ====================================================================
  // 1. ペイロード長のカウント
  //    - payload_sof～payload_eofまでの有効バイト数をカウント
  //    - UDPヘッダ長(8) + ペイロード長を計算
  //    - ゼロ長を一意に扱うため、`UDP_TX_HAS_LEN`時はpayload_lenを優先
  //      payload_len_validが立った時点で長さが確定し、0の場合はヘッダのみ送出
  //    - payload_len_valid後はpayload_sof/eofで長さを再計算しない
  //      (実データ数との不一致時は仕様として対処を決める)
  //
  // 2. UDPヘッダの構成 (RFC 768)
  //    Byte 0-1: Source Port (big-endian)
  //    Byte 2-3: Destination Port (big-endian)
  //    Byte 4-5: Length (ヘッダ8 + データ長)
  //    Byte 6-7: Checksum (疑似ヘッダ含む)
  //
  // 3. チェックサム計算 (RFC 768, RFC 1071)
  //    疑似ヘッダ:
  //      - Source IP (4 bytes)
  //      - Destination IP (4 bytes)
  //      - Zero + Protocol(17) (2 bytes)
  //      - UDP Length (2 bytes)
  //    + UDPヘッダ(チェックサムフィールドは0)
  //    + ペイロード
  //    16ビット単位で1の補数加算 → 1の補数
  //    - チェックサムは必須
  //    - 計算結果が0x0000の場合は0xFFFFを送出する
  //
  // 4. 状態遷移例
  //    IDLE: payload_sofを待つ
  //    BUFFER: ペイロードをバッファ/カウント
  //    HEADER: UDPヘッダ8バイトを出力
  //    PAYLOAD: バッファしたペイロードを出力
  //    - `UDP_TX_HAS_LEN`時は IDLE -> HEADER を許可（payload_len=0）
  //    - packet_sofはヘッダ先頭バイト、packet_eofは最終バイトで1サイクル
  //
  // 5. バックプレッシャー
  //    - バッファ満杯時にpayload_ready=0
  //    - 内部FIFOの実装を推奨
  // ====================================================================

  // TODO: ここに実装を追加
  typedef enum {
    IDLE,
    BUFFER,
    HEADER,
    PAYLOAD
  } state_t;
  state_t current;
  
  logic [15:0] src_port_reg;
  logic [15:0] dst_port_reg;
  logic [31:0] src_ip_reg;
  logic [31:0] dst_ip_reg;
  logic [16:0] sum;
  always_ff begin
    if (!rst_n) begin
      src_port_reg <= '0;
      dst_port_reg <= '0;
      src_ip_reg <= '0;
      dst_ip_reg <= '0;
      sum <= '0;
    end else if (payload_sof) begin
      src_port_reg <= src_port;
      dst_port_reg <= dst_port;
      src_ip_reg <= src_ip;
      dst_ip_reg <= dst_ip;
      sum <= '0;
    end else begin
      sum <= src_ip[31:16] + src_ip[15:0];
      sum <= {16h'0, sum[16]} + sum[15:0] + dst_ip[31:16];
      sum <= {16h'0, sum[16]} + sum[15:0] + dst_ip[15:0];
      sum <= {16h'0, sum[16]} + sum[15:0] + 16'h17;
      sum <= {16h'0, sum[16]} + sum[15:0] + payload_len;
    end
  end
    
  logic [39:0] buffer;
  logic [2:0] payload_cnt;
  logic [3:0] header_cnt;
  logic [15:0] length;
  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) current <= IDLE;
    else begin
      case (current)
        IDLE: begin
          if (payload_sof && payload_valid) begin
            current <= BUFFER;
            buffer <= {buffer[31:8], data_in};
            payload_cnt <= 3'b1;
          end
        end
        BUFFER: begin
          if (!valid_in) begin
            payload_cnt <= payload_cnt;
          end else begin
            if (payload_eof) begin
              current <= HEADER;
              buffer  <= {buffer[31:8], 8'h6F};
            end else begin
              payload_cnt <= payload_cnt + 1;
              buffer <= {buffer[31:8], data_in};
            end
          end
        end
        HEADER: begin
          if (!valid_in) begin
            header_cnt <= header_cnt + 1;
            packet_valid <= 1;
            case (header_cnt)
              0: packet_out <= src_port[15:8];
              1: packet_out <= src_port[7:0];
              2: packet_out <= dst_port[15:8];
              3: packet_out <= dst_port[7:0];
              4: packet_out <= length[15:8];
              5: packet_out <= length[7:0];
              6: ;
              7: ;
            endcase
          end
        end;
        PAYLOAD: ;
      endcase
    end
  end

  assign packet_sof = (header_cnt == 0 && current == HEADER);

endmodule
