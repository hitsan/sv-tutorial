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

  logic [15:0] length;
  logic [15:0] payload_count;
  logic [15:0] payload_len;

  always_comb begin
    payload_len = (length >= 16'd8) ? (length - 16'd8) : 16'd0;
  end

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
          if (payload_count + 1 >= payload_len) begin
            current <= IDLE;
            payload_count <= '0;
          end else begin
            if (valid_in) begin
              payload_count <= payload_count + 1;
            end
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
endmodule
