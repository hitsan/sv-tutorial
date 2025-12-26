// レジスタ (Register)
// 様々なタイプのレジスタ実装

// ============================================================================
// 基本的なD型フリップフロップ（非同期リセット）
// ============================================================================
module dff_async_reset #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,  // アクティブロー（負論理）リセット
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    // always_ff: 順序回路専用のブロック
    // - ノンブロッキング代入 (<=) を使用
    // - 感度リストにクロックエッジとリセットを指定

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= '0;  // リセット時は0にクリア
        end else begin
            q <= d;   // 通常動作: クロックエッジでdを取り込む
        end
    end

    // 注意: '0 はすべてのビットを0にする（幅に依存しない）

endmodule : dff_async_reset


// ============================================================================
// 同期リセット付きレジスタ
// ============================================================================
module dff_sync_reset #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst,   // 同期リセット
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    // 感度リストにはクロックのみ（rstはクロック同期信号）
    always_ff @(posedge clk) begin
        if (rst) begin
            q <= '0;
        end else begin
            q <= d;
        end
    end

    // 同期リセット vs 非同期リセット:
    // - 非同期: rstの変化で即座にリセット
    // - 同期: クロックエッジでのみrstを評価

endmodule : dff_sync_reset


// ============================================================================
// イネーブル付きレジスタ
// ============================================================================
module dff_enable #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,     // イネーブル信号
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= '0;
        end else if (en) begin
            q <= d;  // イネーブル時のみ更新
        end
        // en=0のとき: qは前の値を保持（暗黙的）
    end

    // 用途: データをサンプリングするタイミングを制御

endmodule : dff_enable


// ============================================================================
// リセット値を指定可能なレジスタ
// ============================================================================
module dff_reset_value #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VALUE = '0
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= RESET_VALUE;  // パラメータで指定された値
        end else begin
            q <= d;
        end
    end

endmodule : dff_reset_value


// ============================================================================
// 初期値付きレジスタ（FPGA向け）
// ============================================================================
module dff_init_value #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] INIT_VALUE = '0
) (
    input  logic             clk,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q = INIT_VALUE  // 初期値
);
    // FPGAではレジスタの初期値を設定可能
    // ASICでは通常、初期値は使用できない

    always_ff @(posedge clk) begin
        q <= d;
    end

    // 注意: 初期値とリセット値は異なる
    // - 初期値: 電源投入時の値（FPGAのみ）
    // - リセット値: リセット信号による値（すべてのデバイス）

endmodule : dff_init_value


// ============================================================================
// 汎用レジスタ（すべての機能を含む）
// ============================================================================
module register_generic #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VALUE = '0,
    parameter bit ASYNC_RESET = 1,  // 1=非同期, 0=同期
    parameter bit RESET_ACTIVE_HIGH = 0  // 0=active-low, 1=active-high
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    // generateを使ってリセットタイプを切り替え
    generate
        if (ASYNC_RESET) begin : async_reset_gen
            // 非同期リセット
            if (RESET_ACTIVE_HIGH) begin : active_high
                always_ff @(posedge clk or posedge rst) begin
                    if (rst)
                        q <= RESET_VALUE;
                    else if (en)
                        q <= d;
                end
            end else begin : active_low
                always_ff @(posedge clk or negedge rst) begin
                    if (!rst)
                        q <= RESET_VALUE;
                    else if (en)
                        q <= d;
                end
            end
        end else begin : sync_reset_gen
            // 同期リセット
            always_ff @(posedge clk) begin
                if (RESET_ACTIVE_HIGH ? rst : !rst)
                    q <= RESET_VALUE;
                else if (en)
                    q <= d;
            end
        end
    endgenerate

endmodule : register_generic


// ============================================================================
// レジスタ配列（レジスタファイルの基本）
// ============================================================================
module register_array #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 8
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [$clog2(DEPTH)-1:0] wr_addr,  // 書き込みアドレス
    input  logic                    wr_en,     // 書き込みイネーブル
    input  logic [WIDTH-1:0]        wr_data,   // 書き込みデータ
    input  logic [$clog2(DEPTH)-1:0] rd_addr,  // 読み出しアドレス
    output logic [WIDTH-1:0]        rd_data    // 読み出しデータ
);
    // レジスタ配列の宣言
    logic [WIDTH-1:0] registers [DEPTH];

    // 書き込み処理（同期）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // リセット時にすべてのレジスタをクリア
            for (int i = 0; i < DEPTH; i++) begin
                registers[i] <= '0;
            end
        end else if (wr_en) begin
            registers[wr_addr] <= wr_data;
        end
    end

    // 読み出し処理（組み合わせ回路）
    assign rd_data = registers[rd_addr];

    // または同期読み出し:
    // always_ff @(posedge clk) begin
    //     rd_data <= registers[rd_addr];
    // end

endmodule : register_array


// ============================================================================
// パイプラインレジスタ（複数段）
// ============================================================================
module pipeline_register #(
    parameter int WIDTH = 8,
    parameter int STAGES = 3  // パイプライン段数
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    // パイプラインレジスタ配列
    logic [WIDTH-1:0] pipe [STAGES];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < STAGES; i++) begin
                pipe[i] <= '0;
            end
        end else begin
            // 最初の段
            pipe[0] <= d;
            // 後続の段
            for (int i = 1; i < STAGES; i++) begin
                pipe[i] <= pipe[i-1];
            end
        end
    end

    // 最終段の出力
    assign q = pipe[STAGES-1];

    // 遅延: STAGES クロックサイクル

endmodule : pipeline_register


// ============================================================================
// よくある間違い例（コメントアウト）
// ============================================================================
/*
// 間違い1: always_ffでブロッキング代入
module bad_blocking_assign (
    input  logic clk,
    input  logic [7:0] a, b,
    output logic [7:0] out1, out2
);
    always_ff @(posedge clk) begin
        out1 = a;   // ブロッキング代入（悪い）
        out2 = b;   // レース条件の可能性
    end
    // 修正: <= を使用
endmodule

// 間違い2: 組み合わせ回路でノンブロッキング代入
module bad_nonblocking_comb (
    input  logic [7:0] a, b,
    output logic [7:0] sum
);
    always_comb begin
        sum <= a + b;  // ノンブロッキング代入（悪い）
    end
    // 修正: = を使用
endmodule

// 間違い3: 不完全な感度リスト
module bad_sensitivity (
    input  logic clk, rst, en,
    input  logic [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk) begin  // enとrstが感度リストにない
        if (rst) q <= 0;
        else if (en) q <= d;
    end
    // これは実は正しい（同期リセット・イネーブル）
    // 非同期リセットを意図していた場合は間違い
    // 修正: @(posedge clk or posedge rst)
endmodule
*/


// ============================================================================
// 学習ポイントまとめ
// ============================================================================
// 1. always_ff: 順序回路専用、ノンブロッキング代入(<=)を使用
// 2. 非同期リセット: 感度リストにリセットを追加
// 3. 同期リセット: 感度リストにクロックのみ
// 4. イネーブル: データ更新のタイミングを制御
// 5. パラメータ化: 汎用性と再利用性を向上
// 6. generate: 条件に応じた回路生成
//
// ベストプラクティス:
// - always_ffでは必ずノンブロッキング代入
// - always_combでは必ずブロッキング代入
// - リセット戦略を一貫させる
// - 初期値はFPGAのみ（ASICでは未定義）
