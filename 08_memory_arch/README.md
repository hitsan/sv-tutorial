# メモリアーキテクチャ (Memory Architecture)

## はじめに

このディレクトリでは、メモリシステムとデータ転送の基礎を学習します。
キャッシュメモリとDMA（Direct Memory Access）は、高性能システムにおいて重要な要素です。

## 学習の推奨順序

### 1. Direct-Mapped Cache (direct_mapped_cache/)
- **概要**: 4エントリのダイレクトマップ方式キャッシュメモリ
- **学習内容**: アドレス分解、タグ比較、ヒット/ミス判定、有効ビット管理
- **ファイル**: `direct_mapped_cache/direct_mapped_cache.sv`, `direct_mapped_cache/direct_mapped_cache_tb.sv`

### 2. DMA (Memory to Stream) (dma_m2s/)
- **概要**: メモリからストリームへのDMA転送コントローラ
- **学習内容**: アドレス生成、転送制御、ハンドシェイク、制御レジスタ
- **ファイル**: `dma_m2s/dma_m2s.sv`, `dma_m2s/dma_m2s_tb.sv`

## 参考資料

- Computer Organization and Design - Patterson & Hennessy
- IEEE 1800-2017 SystemVerilog LRM
