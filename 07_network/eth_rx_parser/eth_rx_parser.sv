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
endmodule
