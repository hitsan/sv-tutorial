# テストベンチ基礎 (Testbench Fundamentals)

## はじめに

テストベンチは、設計した回路（DUT: Device Under Test）の機能を検証するためのモジュールです。
このディレクトリでは、SystemVerilogを使った基本的なテストベンチから
高度な検証手法まで学習します。

## テストベンチの目的

1. **機能検証**: 設計が仕様通りに動作することを確認
2. **回帰テスト**: 変更後も既存機能が正常に動作することを確認
3. **カバレッジ**: すべてのコード/機能がテストされたことを確認
4. **バグ検出**: 予期しない動作や問題を発見

## テストベンチの基本構造

```systemverilog
`timescale 1ns / 1ps

module dut_tb;
    // 1. 信号宣言
    logic clk, rst_n;
    logic [7:0] data_in, data_out;

    // 2. DUTのインスタンス化
    my_module dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out)
    );

    // 3. クロック生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns周期 (100MHz)
    end

    // 4. テストシーケンス
    initial begin
        // 初期化
        rst_n = 0;
        data_in = 0;

        // リセット解除
        #20 rst_n = 1;

        // テストケース
        #10 data_in = 8'hAA;
        #10 data_in = 8'h55;

        // 終了
        #100 $finish;
    end

    // 5. 結果確認（オプション）
    initial begin
        $monitor("Time=%0t data_in=%h data_out=%h",
                 $time, data_in, data_out);
    end

endmodule
```

## 学習の推奨順序

### 1. 基本的なテストベンチ
- **学習内容**:
  - `timescale`ディレクティブ
  - 信号宣言（`logic` vs `wire` vs `reg`）
  - DUTのインスタンス化
  - `initial`ブロック
  - `#delay` - 遅延
  - `$display`, `$monitor` - 表示
  - `$finish` - シミュレーション終了

### 2. クロックとリセット
- **学習内容**:
  - クロック生成パターン
  - リセットシーケンス
  - 非同期リセット vs 同期リセット
  - リセット解除のタイミング

### 3. タスクと関数
- **学習内容**:
  - `task` - テスト手順の再利用
  - `function` - 計算の再利用
  - 引数の受け渡し

### 4. アサーション
- **学習内容**:
  - `assert` - 即座の検証
  - SystemVerilog Assertions (SVA)
  - プロパティとシーケンス

### 5. カバレッジ
- **学習内容**:
  - コードカバレッジ
  - 機能カバレッジ
  - `covergroup`と`coverpoint`

## 基本的なテスト手法

### パターン1: 直接的なテスト
```systemverilog
initial begin
    // 各テストケースを明示的に記述
    data_in = 8'h00; #10;
    assert(data_out == expected_value) else $error("Test failed");

    data_in = 8'hFF; #10;
    assert(data_out == expected_value) else $error("Test failed");
end
```

### パターン2: ループを使ったテスト
```systemverilog
initial begin
    for (int i = 0; i < 256; i++) begin
        data_in = i; #10;
        // 検証ロジック
    end
end
```

### パターン3: ランダムテスト
```systemverilog
initial begin
    repeat (1000) begin
        data_in = $urandom_range(0, 255);
        #10;
        // 検証ロジック
    end
end
```

### パターン4: タスクを使った構造化
```systemverilog
task automatic test_case(
    input logic [7:0] input_data,
    input logic [7:0] expected_output
);
    data_in = input_data;
    #10;
    assert(data_out == expected_output)
        else $error("Mismatch: got %h, expected %h",
                    data_out, expected_output);
endtask

initial begin
    test_case(8'hAA, 8'h55);
    test_case(8'h00, 8'hFF);
end
```

## クロック生成パターン

### パターン1: 単純なトグル
```systemverilog
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100MHz
end
```

### パターン2: パラメータ化
```systemverilog
localparam CLK_PERIOD = 10;

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end
```

### パターン3: always ブロック
```systemverilog
always #5 clk = ~clk;

initial clk = 0;
```

## リセット生成パターン

### 非同期リセット（アクティブロー）
```systemverilog
initial begin
    rst_n = 0;        // リセットアサート
    #100;             // リセット期間
    rst_n = 1;        // リセット解除
end
```

### 同期リセット
```systemverilog
initial begin
    rst = 1;
    repeat (5) @(posedge clk);  // 5クロック待機
    rst = 0;
end
```

## タイミング制御

### 遅延ベース
```systemverilog
#10;           // 10時間単位の遅延
#10ns;         // 10ナノ秒の遅延（timescale依存）
```

### イベントベース
```systemverilog
@(posedge clk);           // クロックの立ち上がりまで待機
@(negedge clk);           // クロックの立ち下がりまで待機
wait(ready == 1);         // 条件が真になるまで待機
@(posedge clk iff valid); // 条件付きイベント
```

### 複数クロック待機
```systemverilog
repeat (10) @(posedge clk);  // 10クロック待機
##10;                        // SVAスタイル: 10クロック待機
```

## よくある間違いと対策

### 間違い1: レース条件
```systemverilog
// 悪い例: ノンブロッキング代入とクロックエッジが競合
initial begin
    @(posedge clk);
    data <= new_value;  // レース条件の可能性
end

// 良い例: クロック後に遅延を追加
initial begin
    @(posedge clk);
    #1 data = new_value;  // クロックエッジ後に代入
end

// またはブロッキング代入
initial begin
    @(posedge clk);
    data = new_value;
end
```

### 間違い2: 初期化忘れ
```systemverilog
// 悪い例: 信号が未初期化
logic enable;
// enableは'x'（不定）

// 良い例: 明示的に初期化
logic enable = 0;
// またはinitialブロックで初期化
```

### 間違い3: タイムアウト保護なし
```systemverilog
// 悪い例: 無限ループの可能性
wait(done == 1);

// 良い例: タイムアウト保護
fork
    begin
        wait(done == 1);
    end
    begin
        #1000;
        $error("Timeout waiting for done");
    end
join_any
```

## 便利なシステムタスク

### 表示・デバッグ
```systemverilog
$display("Hello");                    // 即座に表示
$monitor("a=%d b=%d", a, b);         // 変化時に表示
$strobe("Time=%t", $time);           // タイムステップ終了時に表示
$write("No newline");                // 改行なし表示
```

### 時間関連
```systemverilog
$time;          // 現在のシミュレーション時間
$realtime;      // 実数型の時間
$printtimescale(module_name); // タイムスケール表示
```

### ファイルI/O
```systemverilog
integer fd;
fd = $fopen("output.txt", "w");
$fwrite(fd, "data=%h\n", data);
$fclose(fd);
```

### 波形ダンプ
```systemverilog
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);  // すべての信号をダンプ
end
```

### ランダム値生成
```systemverilog
$random;                        // 符号付き32ビット乱数
$urandom;                       // 符号なし32ビット乱数
$urandom_range(min, max);       // 範囲指定乱数
```

## ベストプラクティス

1. **明確なテストケース**: 各テストの目的を明確に
2. **自己チェック**: assertで自動的に検証
3. **メッセージング**: エラー時に有用な情報を出力
4. **タイムアウト保護**: ハング防止
5. **波形ダンプ**: デバッグ用に波形を保存
6. **コメント**: テストの意図を記述
7. **モジュラー**: taskで再利用性を高める

## 次のステップ

- **次**: SystemVerilog Assertions (SVA)
- **次**: カバレッジ駆動検証
- **次**: 制約付きランダム検証 (CRV)
- **高度**: Universal Verification Methodology (UVM)

## 参考資料

- `../rtl/combinational/mux2x1_tb.sv` - 基本的なテストベンチ例
- IEEE 1800-2017 SystemVerilog LRM
- 各ref/ディレクトリのテストベンチサンプル
