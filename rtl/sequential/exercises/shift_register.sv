// シフトレジスタの各種実装例
// 様々なタイプのシフトレジスタ

`timescale 1ns / 100ps

// ============================================================================
// 例1: 基本的な右シフトレジスタ (SISO: Serial-In Serial-Out)
// ============================================================================
// 要件:
// - クロックごとにデータを右にシフト
// - serial_inを最上位ビットに取り込む
// - 最下位ビットをserial_outに出力
module shift_reg_right #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             serial_in,
    output logic             serial_out,
    output logic [WIDTH-1:0] parallel_out
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      parallel_out <= '0;
      serial_out <= '0;
    end else begin
      parallel_out <= {serial_in, parallel_out[WIDTH-1:1]};
      serial_out <= parallel_out[0];
    end
  end
endmodule : shift_reg_right


// ============================================================================
// 例2: 左シフトレジスタ
// ============================================================================
// 要件:
// - クロックごとにデータを左にシフト
// - serial_inを最下位ビットに取り込む
// - 最上位ビットをserial_outに出力
module shift_reg_left #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             serial_in,
    output logic             serial_out,
    output logic [WIDTH-1:0] parallel_out
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      serial_out <= '0;
      parallel_out <= '0;
    end
    else begin
      parallel_out <= {parallel_out[WIDTH-2:0], serial_in};
      serial_out <= parallel_out[WIDTH-1];
    end
  end

endmodule : shift_reg_left


// ============================================================================
// 例3: パラレルロード付きシフトレジスタ (PISO: Parallel-In Serial-Out)
// ============================================================================
// 要件:
// - load信号が1のときにparallel_inをロード
// - load信号が0のときに右シフト動作
module shift_reg_piso #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             load,
    input  logic [WIDTH-1:0] parallel_in,
    input  logic             serial_in,
    output logic             serial_out
);
  logic [WIDTH-1:0] data_reg;
  assign serial_out = data_reg[0];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) data_reg <= '0;
    else if (load) data_reg <= parallel_in;
    else data_reg <= {serial_in, data_reg[WIDTH-1:1]};
  end

endmodule : shift_reg_piso


// ============================================================================
// 例4: 双方向シフトレジスタ
// ============================================================================
// 要件:
// - dir信号で方向を制御 (1=右, 0=左)
// - 右シフト時: serial_in_rightを使用
// - 左シフト時: serial_in_leftを使用
module shift_reg_bidirectional #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             dir,            // 1=right, 0=left
    input  logic             serial_in_right,
    input  logic             serial_in_left,
    output logic             serial_out_right,
    output logic             serial_out_left,
    output logic [WIDTH-1:0] parallel_out
);
  assign serial_out_right = parallel_out[0];
  assign serial_out_left = parallel_out[WIDTH-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) parallel_out <= '0;
    else if (dir) parallel_out <= {serial_in_right, parallel_out[WIDTH-1:1]};
    else parallel_out <= {parallel_out[WIDTH-2:0], serial_in_left};
  end
endmodule : shift_reg_bidirectional


// ============================================================================
// 例5: ユニバーサルシフトレジスタ
// ============================================================================
// 要件:
// - mode信号で動作を制御
//   00: ホールド（変化なし）
//   01: 右シフト
//   10: 左シフト
//   11: パラレルロード
module shift_reg_universal #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [1:0]       mode,
    input  logic             serial_in_right,
    input  logic             serial_in_left,
    input  logic [WIDTH-1:0] parallel_in,
    output logic             serial_out_right,
    output logic             serial_out_left,
    output logic [WIDTH-1:0] parallel_out
);
  assign serial_out_right = parallel_out[0];
  assign serial_out_left = parallel_out[WIDTH-1];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) parallel_out <= '0;
    else begin
      casez (mode)
        2'b00: parallel_out <= parallel_out;
        2'b01: parallel_out <= {serial_in_right, parallel_out[WIDTH-1:1]};
        2'b10: parallel_out <= {parallel_out[WIDTH-2:0], serial_in_left};
        2'b11: parallel_out <= parallel_in;
      endcase
    end
  end
endmodule : shift_reg_universal


// ============================================================================
// 例6: リングカウンタ（循環シフトレジスタ）
// ============================================================================
// 要件:
// - 最上位ビットが最下位ビットにフィードバック
// - 初期値は1ビットのみ'1'
module shift_reg_ring #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    output logic [WIDTH-1:0] ring_out
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) ring_out <= 1;
    else ring_out <= {ring_out[WIDTH-2:0], ring_out[WIDTH-1]};
  end
endmodule : shift_reg_ring


// ============================================================================
// 学習ポイントまとめ
// ============================================================================
// 1. 右シフト: {serial_in, data[WIDTH-1:1]}
// 2. 左シフト: {data[WIDTH-2:0], serial_in}
// 3. パラレルロード: 制御信号でロードとシフトを切り替え
// 4. 双方向: 方向制御信号でシフト方向を選択
// 5. ユニバーサル: モード信号で複数の動作を実現
// 6. リング: フィードバック接続で循環動作
//
// 応用例:
// - シリアル通信 (UART, SPI)
// - データ変換 (シリアル⇔パラレル)
// - 遅延回路
// - パターン生成/検出
