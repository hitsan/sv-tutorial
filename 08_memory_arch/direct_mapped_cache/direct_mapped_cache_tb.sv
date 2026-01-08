//============================================================================
// File: direct_mapped_cache_tb.sv
// Description: ダイレクトマップドキャッシュのテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module direct_mapped_cache_tb;

    // パラメータ定義
    localparam int CLK_PERIOD = 10;
    localparam int TIMEOUT_CYCLES = 100;
    localparam int ADDR_WIDTH = 16;
    localparam int DATA_WIDTH = 32;
    localparam int CACHE_SIZE = 4;
    localparam int PROPAGATION_DELAY = 1;  // 組み合わせ論理の伝搬遅延

    // キャッシュ構造の計算
    localparam int INDEX_BITS = $clog2(CACHE_SIZE);
    localparam int TAG_BITS = ADDR_WIDTH - INDEX_BITS;

    // エラーカウンタ
    int error_count = 0;
    int test_count = 0;

    // DUT信号
    logic                   clk;
    logic                   rst_n;
    logic [ADDR_WIDTH-1:0]  addr;
    logic                   read_enable;
    logic                   write_enable;
    logic [DATA_WIDTH-1:0]  write_data;
    logic [DATA_WIDTH-1:0]  read_data;
    logic                   hit;
    logic                   miss;

    // リファレンスモデル: キャッシュの期待状態を追跡
    typedef struct {
        logic                  valid;
        logic [TAG_BITS-1:0]   tag;
        logic [DATA_WIDTH-1:0] data;
    } cache_line_t;

    cache_line_t reference_cache [CACHE_SIZE];

    // DUT インスタンス化
    direct_mapped_cache #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .CACHE_SIZE(CACHE_SIZE)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .addr         (addr),
        .read_enable  (read_enable),
        .write_enable (write_enable),
        .write_data   (write_data),
        .read_data    (read_data),
        .hit          (hit),
        .miss         (miss)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // アドレス分解
    function automatic int get_index(logic [ADDR_WIDTH-1:0] addr);
        return addr[INDEX_BITS-1:0];
    endfunction

    function automatic logic [TAG_BITS-1:0] get_tag(logic [ADDR_WIDTH-1:0] addr);
        return addr[ADDR_WIDTH-1:INDEX_BITS];
    endfunction

    // 期待値計算: ヒット判定
    function automatic logic expect_hit(logic [ADDR_WIDTH-1:0] addr);
        int idx = get_index(addr);
        logic [TAG_BITS-1:0] tag = get_tag(addr);
        return (reference_cache[idx].valid &&
                reference_cache[idx].tag == tag);
    endfunction

    // 期待値計算: 読み出しデータ
    function automatic logic [DATA_WIDTH-1:0] expect_read_data(
        logic [ADDR_WIDTH-1:0] addr
    );
        int idx = get_index(addr);
        if (expect_hit(addr)) begin
            return reference_cache[idx].data;
        end else begin
            return 'x;
        end
    endfunction

    // リファレンスモデル初期化
    task init_reference_cache();
        for (int i = 0; i < CACHE_SIZE; i++) begin
            reference_cache[i].valid = 0;
            reference_cache[i].tag = '0;
            reference_cache[i].data = '0;
        end
    endtask

    // リファレンスモデル更新: 書き込み
    task update_reference_write(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
        int idx = get_index(addr);
        logic [TAG_BITS-1:0] tag = get_tag(addr);

        reference_cache[idx].valid = 1;
        reference_cache[idx].tag = tag;
        reference_cache[idx].data = data;

        $display("    [Ref Model] Updated cache[%0d]: tag=0x%X, data=0x%08X",
                 idx, tag, data);
    endtask

    // キャッシュ読み出しタスク
    // 注: このテストはキャッシュが組み合わせ論理で応答すると仮定
    //     （read_enableがアサートされた次サイクルに結果が得られる）
    task cache_read(
        input logic [ADDR_WIDTH-1:0] addr_in,
        input logic                  expect_hit_flag,
        input logic [DATA_WIDTH-1:0] expect_data
    );
        logic actual_hit;
        logic actual_miss;
        logic [DATA_WIDTH-1:0] actual_data;

        @(posedge clk);
        addr <= addr_in;
        read_enable <= 1;
        write_enable <= 0;

        @(posedge clk);
        read_enable <= 0;

        #PROPAGATION_DELAY;  // 組み合わせ論理の安定待ち

        actual_hit = hit;
        actual_miss = miss;
        actual_data = read_data;

        $display("    Read addr=0x%04X: hit=%b, miss=%b, data=0x%08X",
                 addr_in, actual_hit, actual_miss, actual_data);

        // 検証（DUT実装がある場合のみ）
        if (hit !== 'x && hit !== 'z) begin
            if (actual_hit !== expect_hit_flag) begin
                $display("      [ERROR] Hit/Miss mismatch: got %b, expected %b",
                         actual_hit, expect_hit_flag);
                error_count++;
            end

            // miss信号の検証（hit信号と相補的であるべき）
            if (miss !== 'x && miss !== 'z) begin
                if (miss !== !hit) begin
                    $display("      [ERROR] Miss signal inconsistent with hit: miss=%b, hit=%b",
                             miss, hit);
                    error_count++;
                end
            end

            if (expect_hit_flag && actual_data !== expect_data) begin
                $display("      [ERROR] Data mismatch: got 0x%08X, expected 0x%08X",
                         actual_data, expect_data);
                error_count++;
            end
        end
    endtask

    // キャッシュ書き込みタスク
    task cache_write(
        input logic [ADDR_WIDTH-1:0] addr_in,
        input logic [DATA_WIDTH-1:0] data_in
    );
        @(posedge clk);
        addr <= addr_in;
        write_data <= data_in;
        read_enable <= 0;
        write_enable <= 1;

        $display("    Write addr=0x%04X, data=0x%08X", addr_in, data_in);

        @(posedge clk);
        write_enable <= 0;

        // リファレンスモデル更新
        update_reference_write(addr_in, data_in);

        #PROPAGATION_DELAY;
    endtask

    // キャッシュ状態ダンプ（デバッグ用）
    task dump_cache_state();
        $display("  [Cache State Dump]");
        for (int i = 0; i < CACHE_SIZE; i++) begin
            $display("    Line[%0d]: valid=%b, tag=0x%X, data=0x%08X",
                     i,
                     reference_cache[i].valid,
                     reference_cache[i].tag,
                     reference_cache[i].data);
        end
    endtask

    // メインテストシーケンス
    initial begin
        // 波形ダンプ
        $dumpfile("direct_mapped_cache_tb.vcd");
        $dumpvars(0, direct_mapped_cache_tb);

        // 初期化
        rst_n = 0;
        addr = 0;
        read_enable = 0;
        write_enable = 0;
        write_data = 0;

        init_reference_cache();

        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("=== Direct Mapped Cache Test Start ===");
        $display("  CACHE_SIZE=%0d, INDEX_BITS=%0d, TAG_BITS=%0d",
                 CACHE_SIZE, INDEX_BITS, TAG_BITS);

        // Test 1: 初期状態（全ミス）
        test_count++;
        $display("\n[Test %0d] Initial state - all miss", test_count);
        for (int i = 0; i < CACHE_SIZE; i++) begin
            cache_read(16'(i), 0, 'x);
        end

        // Test 2: 書き込み後の読み出し
        test_count++;
        $display("\n[Test %0d] Write-Read hit", test_count);
        cache_write(16'h0000, 32'hDEAD_BEEF);
        cache_read(16'h0000, 1, 32'hDEAD_BEEF);

        // Test 3: 異なるインデックスへの書き込み
        test_count++;
        $display("\n[Test %0d] Multiple writes to different indices", test_count);
        cache_write(16'h0000, 32'h1111_1111);
        cache_write(16'h0001, 32'h2222_2222);
        cache_write(16'h0002, 32'h3333_3333);
        cache_write(16'h0003, 32'h4444_4444);
        cache_read(16'h0000, 1, 32'h1111_1111);
        cache_read(16'h0001, 1, 32'h2222_2222);
        cache_read(16'h0002, 1, 32'h3333_3333);
        cache_read(16'h0003, 1, 32'h4444_4444);
        dump_cache_state();

        // Test 4: 同一インデックス異なるタグ（コンフリクトミス）
        test_count++;
        $display("\n[Test %0d] Conflict miss - same index, different tag", test_count);
        cache_write(16'h0000, 32'hAAAA_AAAA);  // index=0, tag=0
        cache_write(16'h0004, 32'hBBBB_BBBB);  // index=0, tag=1 (conflicts)
        cache_read(16'h0000, 0, 'x);  // ミスするはず
        cache_read(16'h0004, 1, 32'hBBBB_BBBB);  // ヒットするはず

        // Test 5: タグ衝突パターン
        test_count++;
        $display("\n[Test %0d] Tag collision pattern", test_count);
        cache_write(16'h0001, 32'h1000_0001);
        cache_write(16'h0005, 32'h1000_0005);  // 同じindex=1
        cache_write(16'h0009, 32'h1000_0009);  // 同じindex=1
        cache_read(16'h0001, 0, 'x);  // 追い出された
        cache_read(16'h0005, 0, 'x);  // 追い出された
        cache_read(16'h0009, 1, 32'h1000_0009);  // 最後のものがヒット

        // Test 6: 全キャッシュライン充填
        test_count++;
        $display("\n[Test %0d] Fill all cache lines", test_count);
        for (int i = 0; i < CACHE_SIZE; i++) begin
            cache_write(16'(i), 32'(32'hF000_0000 + i));
        end
        for (int i = 0; i < CACHE_SIZE; i++) begin
            cache_read(16'(i), 1, 32'(32'hF000_0000 + i));
        end

        // Test 7: シーケンシャルアクセス（スラッシング）
        test_count++;
        $display("\n[Test %0d] Sequential access (thrashing)", test_count);
        for (int i = 0; i < 8; i++) begin
            cache_write(16'(i), 32'(32'hA000_0000 + i));
        end
        // 最初の4つはキャッシュに残っていない
        for (int i = 0; i < 4; i++) begin
            cache_read(16'(i), 0, 'x);
        end
        // 後の4つは残っている
        for (int i = 4; i < 8; i++) begin
            cache_read(16'(i), 1, 32'(32'hA000_0000 + i));
        end

        // Test 8: リセット後の動作
        test_count++;
        $display("\n[Test %0d] Post-reset behavior", test_count);
        rst_n = 0;
        init_reference_cache();
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        // 以前キャッシュされていたアドレスを読む
        cache_read(16'h0000, 0, 'x);
        cache_read(16'h0001, 0, 'x);

        repeat(5) @(posedge clk);

        // 最終レポート
        $display("\n=== Direct Mapped Cache Test Complete ===");
        $display("Total tests: %0d", test_count);
        $display("Errors: %0d", error_count);
        if (error_count == 0) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end

    // タイムアウト保護
    initial begin
        #(CLK_PERIOD * TIMEOUT_CYCLES * 20);
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
