`timescale 1ns/1ps
module hw_scheduler_tb;
    // パラメータ
    parameter int NUM_REQUESTERS = 4;
    parameter int CLK_PERIOD = 10;

    // 信号宣言
    logic                      clk;
    logic                      rst_n;
    logic [NUM_REQUESTERS-1:0] request;
    logic [NUM_REQUESTERS-1:0] grant;

    // DUTインスタンス化
    hw_scheduler #(
        .NUM_REQUESTERS(NUM_REQUESTERS)
    ) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .request (request),
        .grant   (grant)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // アサーション
    // 同時に複数のgrantが立たない（0個またはホットビット1個のみ）
    property p_onehot_grant;
        @(posedge clk) disable iff (!rst_n)
            $onehot0(grant);
    endproperty
    assert property (p_onehot_grant) else $error("Multiple grants asserted simultaneously");

    // requestがある時は必ず1つgrantが立つ
    property p_grant_on_request;
        @(posedge clk) disable iff (!rst_n)
            (|request) |-> (|grant);
    endproperty
    assert property (p_grant_on_request) else $error("Request exists but no grant asserted");

    // grantはrequestのサブセット
    property p_grant_subset_request;
        @(posedge clk) disable iff (!rst_n)
            (grant & ~request) == 0;
    endproperty
    assert property (p_grant_subset_request) else $error("Grant asserted without corresponding request");

    // テストタスク
    task reset_dut();
        @(posedge clk);  // クロックエッジに同期
        rst_n = 0;
        request = 0;
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("[%0t] Reset completed", $time);
    endtask

    task wait_cycles(int n);
        repeat(n) @(posedge clk);
    endtask

    task test_single_request(int req_num);
        $display("[%0t] Test: Single request [%0d]", $time, req_num);
        request = 1 << req_num;
        // DUTがレジスタ経由でgrantを出力する場合は2サイクル待つ
        wait_cycles(2);
        if (grant[req_num]) begin
            $display("  PASS: Grant asserted for requester %0d", req_num);
        end else begin
            $error("  FAIL: Grant NOT asserted for requester %0d", req_num);
        end
        request = 0;
        wait_cycles(1);
    endtask

    task test_round_robin();
        int grant_order[$];

        $display("[%0t] Test: Round-robin arbitration", $time);

        // 全リクエスターがリクエスト
        request = '1;

        // NUM_REQUESTERS回グラントをモニタ
        for (int i = 0; i < NUM_REQUESTERS; i++) begin
            @(posedge clk);
            #1;  // クロックエッジ直後にサンプル
            // どのビットがグラントされたか記録
            for (int j = 0; j < NUM_REQUESTERS; j++) begin
                if (grant[j]) begin
                    grant_order.push_back(j);
                    $display("  Cycle %0d: Grant[%0d] asserted", i, j);
                    break;
                end
            end
        end

        // ラウンドロビンの順序性をチェック（各リクエスターが1回ずつグラントされる）
        if (grant_order.size() == NUM_REQUESTERS) begin
            // 全リクエスターが1回ずつグラントされたかチェック
            int seen[NUM_REQUESTERS];
            foreach (seen[i]) seen[i] = 0;
            foreach (grant_order[i]) seen[grant_order[i]]++;

            int all_once = 1;
            foreach (seen[i]) begin
                if (seen[i] != 1) all_once = 0;
            end

            if (all_once) begin
                $display("  PASS: All requesters granted exactly once");
            end else begin
                $error("  FAIL: Round-robin fairness violation");
            end
        end else begin
            $error("  FAIL: Expected %0d grants, got %0d", NUM_REQUESTERS, grant_order.size());
        end

        request = 0;
        wait_cycles(1);
    endtask

    task test_no_request();
        $display("[%0t] Test: No request", $time);
        request = 0;
        wait_cycles(2);
        if (grant == 0) begin
            $display("  PASS: No grant when no request");
        end else begin
            $error("  FAIL: Grant asserted without request");
        end
    endtask

    task test_priority_rotation();
        $display("[%0t] Test: Priority rotation", $time);

        // リクエスター2のみリクエスト
        request = 4'b0100;
        // DUTの応答を待つ（レジスタ経由の場合は複数サイクル必要）
        wait_cycles(2);
        if (grant[2]) begin
            $display("  Step 1 PASS: Requester 2 granted");
        end else begin
            $error("  Step 1 FAIL: Requester 2 NOT granted");
        end

        // リクエスター0のみリクエスト（優先度は3に移動しているはず）
        request = 4'b0001;
        wait_cycles(2);
        if (grant[0]) begin
            $display("  Step 2 PASS: Requester 0 granted");
        end else begin
            $error("  Step 2 FAIL: Requester 0 NOT granted");
        end

        request = 0;
        wait_cycles(1);
    endtask

    task test_dynamic_requests();
        int errors = 0;
        $display("[%0t] Test: Dynamic request changes", $time);

        // 複数リクエスト → 1つずつ減らす
        request = 4'b1111;
        wait_cycles(1);
        if (!(|grant)) begin
            $error("  Step 1: No grant asserted for request=0b1111");
            errors++;
        end

        request = 4'b0111;
        wait_cycles(1);
        if (grant[3]) begin
            $error("  Step 2: Grant[3] asserted without request");
            errors++;
        end
        if (!(|grant)) begin
            $error("  Step 2: No grant asserted for request=0b0111");
            errors++;
        end

        request = 4'b0011;
        wait_cycles(1);
        if (grant[3] || grant[2]) begin
            $error("  Step 3: Grant asserted without corresponding request");
            errors++;
        end
        if (!(|grant)) begin
            $error("  Step 3: No grant asserted for request=0b0011");
            errors++;
        end

        request = 4'b0001;
        wait_cycles(1);
        if (grant != 4'b0001 && grant != 4'b0000) begin
            $error("  Step 4: Unexpected grant pattern: %b", grant);
            errors++;
        end

        if (errors == 0) begin
            $display("  PASS: Dynamic request test completed");
        end else begin
            $error("  FAIL: %0d errors in dynamic request test", errors);
        end

        request = 0;
        wait_cycles(1);
    endtask

    // メインテストシーケンス
    initial begin
        // 波形ダンプ
        $dumpfile("hw_scheduler_tb.vcd");
        $dumpvars(0, hw_scheduler_tb);

        $display("========================================");
        $display("hw_scheduler Testbench Start");
        $display("========================================");

        // 初期化
        reset_dut();

        // テストケース実行
        test_no_request();

        // 各リクエスターの単独テスト
        for (int i = 0; i < NUM_REQUESTERS; i++) begin
            test_single_request(i);
        end

        test_round_robin();
        test_priority_rotation();
        test_dynamic_requests();

        // 終了
        wait_cycles(5);
        $display("========================================");
        $display("hw_scheduler Testbench Completed");
        $display("========================================");
        $finish;
    end

    // タイムアウト
    initial begin
        #100000;
        $error("Testbench timeout");
        $finish;
    end

endmodule
