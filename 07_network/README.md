# ネットワーク処理 (Network Processing)

## はじめに

このディレクトリでは、ネットワークプロトコル（Ethernet, UDP）の基礎的な実装を学習します。
ハードウェアによるパケット処理は、高速ネットワーク機器やネットワークアクセラレータで重要な技術です。

教育目的のため、プロトコルは簡素化されていますが、実際のネットワーク処理の基本概念を理解できます。

## 基本原則: 回路を設計してから、コードを書く

ネットワーク処理回路の設計では、**プロトコル階層**と**データフロー**を明確にすることが重要です。

1. **プロトコル階層の理解**: Ethernet → IP → UDP の各層の役割を把握
2. **パケット構造の把握**: ヘッダフィールドの位置とサイズ
3. **ステートマシン設計**: パーサやジェネレータの状態遷移
4. **データフローの設計**: valid/ready ハンドシェイクによるフロー制御

## 学習の推奨順序

### 1. CRC32 (crc32/crc32.sv)
- **概要**: Ethernet CRC32（巡回冗長検査）計算モジュール
- **学習内容**:
  - LFSR（線形帰還シフトレジスタ）の実装
  - CRCの基本原理とビット演算
  - ストリーミングインターフェース（valid/ready）
  - Ethernet CRC32多項式（0x04C11DB7）の使用
- **重要ポイント**:
  - CRCは誤り検出用（訂正はできない）
  - LFSRによる効率的な実装
  - バイト単位での処理（8ビット/サイクル）
  - 初期値とFinal XOR
- **実装例**: 8ビット/サイクル、パラメータ化多項式
- **ファイル**: `crc32/crc32.sv`, `crc32/crc32_tb.sv`

### 2. Ethernet RX Parser (eth_rx_parser/eth_rx_parser.sv)
- **概要**: Ethernetフレームの受信パーサ（簡易版）
- **学習内容**:
  - プロトコルパーサの基本構造
  - FSMによるパケット処理
  - フィールド抽出ロジック
  - プリアンブル検出とフレーム同期
  - MACアドレス、EtherType/Lengthの解析
  - 03_fsmで学んだステートマシンの応用
- **重要ポイント**:
  - Ethernetフレーム構造の理解
  - バイトストリーム処理
  - 状態遷移によるフィールド順次解析
  - CRCチェック（省略可能）
- **実装例**:
  - プリアンブル検出
  - 宛先/送信元MACアドレス抽出
  - EtherType解析
  - ペイロード出力
- **ファイル**: `eth_rx_parser/eth_rx_parser.sv`, `eth_rx_parser/eth_rx_parser_tb.sv`

### 3. UDP RX (udp_rx/udp_rx.sv)
- **概要**: UDPパケットの受信処理モジュール（簡易版、IPv4前提）
- **学習内容**:
  - UDPヘッダ解析
  - ポート番号フィルタリング
  - ペイロード抽出
  - マルチレイヤプロトコル処理
- **重要ポイント**:
  - IPヘッダはスキップ（簡易化）
  - UDPヘッダフィールド（送信元/宛先ポート、長さ、チェックサム）
  - ポートマッチング
  - チェックサム検証（オプショナル）
- **実装例**:
  - 固定ポートへのフィルタリング
  - ヘッダ除去とペイロード出力
- **ファイル**: `udp_rx/udp_rx.sv`, `udp_rx/udp_rx_tb.sv`

### 4. UDP TX (udp_tx/udp_tx.sv)
- **概要**: UDPパケットの送信生成モジュール
- **学習内容**:
  - UDPヘッダ生成
  - パケット組み立て
  - ヘッダ挿入ロジック
  - 長さ計算
- **重要ポイント**:
  - ペイロード長からUDP長を計算
  - チェックサム計算（簡易版ではスキップ可能）
  - ヘッダ+ペイロードの連結
  - バイトオーダー（ネットワークバイトオーダーはビッグエンディアン）
- **実装例**:
  - 固定送信元/宛先ポート
  - ヘッダ自動生成
  - ペイロード受信とパケット送出
- **ファイル**: `udp_tx/udp_tx.sv`, `udp_tx/udp_tx_tb.sv`

### 5. Network Example (network_example/simple_udp_loopback.sv)
- **概要**: UDPエコーサーバの統合実装例
- **学習内容**:
  - 複数モジュールの統合
  - データフロー管理
  - アドレス/ポートのスワップ
  - エンドツーエンドのパケット処理
  - 04_structuralで学んだモジュール接続の実践
- **重要ポイント**:
  - eth_rx_parser → udp_rx → udp_tx → crc32 の接続
  - アドレス/ポート入れ替えロジック
  - フロー制御とバックプレッシャー
  - デバッグとシミュレーション
- **実装例**:
  - 受信UDPパケットをそのままエコーバック
  - 送信元と宛先を入れ替え
  - 簡易的なネットワークスタック
- **ファイル**: `network_example/simple_udp_loopback.sv`, `network_example/simple_udp_loopback_tb.sv`

## プロトコル階層とフレーム構造

### Ethernetフレーム（簡易版）

```
| Preamble | SFD | DA | SA | Type/Length | Payload | FCS (CRC32) |
  8 bytes    1B   6B   6B      2B          46-1500B      4B
```

- **Preamble**: 同期用（0xAA...）
- **SFD**: Start Frame Delimiter（0xAB）
- **DA**: Destination MAC Address
- **SA**: Source MAC Address
- **Type/Length**: EtherType（例：0x0800 = IPv4）
- **Payload**: データ
- **FCS**: Frame Check Sequence（CRC32）

### UDPパケット（IPv4内）

```
| IP Header | UDP Header | UDP Payload |
   20B          8B          可変長
```

**UDPヘッダ**:
```
| Source Port | Dest Port | Length | Checksum |
     2B           2B         2B        2B
```

## ベストプラクティス

1. **ステートマシン設計**: パーサは明確な状態遷移を持つFSMで実装
2. **バイトカウンタ**: フィールド境界の管理にカウンタを使用
3. **エンディアン注意**: ネットワークはビッグエンディアン
4. **エラー処理**: 不正パケットの検出と破棄
5. **フロー制御**: ready信号によるバックプレッシャー対応

## よくある間違いと対策

### 間違い1: バイトオーダーの誤り

```systemverilog
// 悪い例: エンディアン考慮なし
logic [15:0] port;
port = {byte0, byte1};  // Little Endianになってしまう

// 良い例: ビッグエンディアンに変換
logic [15:0] port;
port = {byte1, byte0};  // Network Byte Order (Big Endian)
```

### 間違い2: 状態遷移の不備

```systemverilog
// 悪い例: エラー時の復帰処理なし
case (state)
    PARSE_HEADER: ...
    PARSE_PAYLOAD: ...
    // エラー状態への遷移なし → ハング
endcase

// 良い例: エラー処理を追加
case (state)
    PARSE_HEADER: begin
        if (error) state <= IDLE;  // エラー時はIDLEへ
    end
    PARSE_PAYLOAD: ...
    default: state <= IDLE;  // 不正状態から復帰
endcase
```

### 間違い3: CRC計算タイミングの誤り

```systemverilog
// 悪い例: 全データ受信後にCRC計算
// → 大きなバッファが必要

// 良い例: ストリーミングCRC計算
// → データを受信しながらLFSRを更新
```

### 間違い4: フロー制御の未実装

```systemverilog
// 悪い例: バックプレッシャーなし
// → 下流が処理できない場合にデータロス

// 良い例: ready信号でフロー制御
assign ready_out = downstream_ready;
```

## CRC32の基礎

### CRC（Cyclic Redundancy Check）

- **目的**: データの誤り検出
- **原理**: 多項式除算の剰余を利用
- **Ethernet CRC32**:
  - 多項式: `x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1`
  - 16進: `0x104C11DB7` または `0x04C11DB7`（最上位ビット省略）

### LFSR実装

```systemverilog
// 簡略化例（実際は8ビットパラレル処理）
always_ff @(posedge clk) begin
    if (data_valid) begin
        for (int i = 0; i < 8; i++) begin
            feedback = crc[31] ^ data[i];
            crc = {crc[30:0], 1'b0} ^ (feedback ? POLY : 32'h0);
        end
    end
end
```

## パフォーマンス考慮事項

| モジュール | スループット | レイテンシ | リソース |
|-----------|------------|----------|---------|
| CRC32 | 8ビット/cycle | 1 cycle | 小 |
| Eth Parser | 8ビット/cycle | 数十cycles | 小 |
| UDP RX/TX | 8ビット/cycle | 数cycles | 小 |
| Loopback | 8ビット/cycle | 数十cycles | 中 |

## 応用例

1. **パケットフィルタ**: 特定のMACアドレスやポートのみ通過
2. **ルータ**: IPヘッダ解析と転送
3. **ファイアウォール**: パケット検査とフィルタリング
4. **プロトコルアクセラレータ**: TCP/IP処理のオフロード
5. **ネットワークモニタ**: パケットキャプチャと解析

## 参考資料

- IEEE 802.3 Ethernet Standard
- RFC 768 (UDP)
- RFC 791 (IP)
- Computer Networks - Tanenbaum & Wetherall
- 詳細な説明は各ソースファイル内のコメントを参照
