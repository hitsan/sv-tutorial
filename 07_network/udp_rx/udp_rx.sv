// UDP RX (受信)
// UDPヘッダ解析とペイロード抽出
// すべてのUDPパケットを解析し、ポート情報とペイロードを出力

`timescale 1ns / 1ps
module udp_rx #(
    parameter int DATA_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [DATA_WIDTH-1:0]  data_in,
    input  logic                   valid_in,
    output logic [15:0]            src_port,
    output logic [15:0]            dst_port,
    output logic [DATA_WIDTH-1:0]  payload_out,
    output logic                   payload_valid
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
    // 2. Lengthフィールドの処理（重要）
    //    - UDP Lengthフィールド = ヘッダ(8) + ペイロード長
    //    - ペイロード長 = Length - 8
    //    - Lengthで指定された分だけペイロードを出力
    //    - それ以上のデータは破棄する
    //
    // 3. ペイロード出力制御
    //    - payload_countカウンタを用意
    //    - payload_count < (Length - 8) の間だけpayload_valid=1
    //    - Lengthに達したらIDLEへ遷移（valid_in=1でも終了）
    //
    // 4. エラー処理
    //    - ヘッダ受信中にvalid_in=0 → IDLEへ戻る
    //    - ペイロード受信中のvalid_in=0は一時停止として扱う
    //
    // 5. チェックサム
    //    - 簡易版のため検証不要（読み捨て）
    //
    // ヒント:
    // - 上位バイトを保持するレジスタが必要
    // - ポート番号とLength値は出力用レジスタに格納
    // - 組み合わせ回路でデフォルト値を必ず設定（ラッチ防止）

endmodule
