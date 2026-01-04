# 制御ロジック (Control Logic)

## はじめに

このディレクトリでは、ハードウェアスケジューリングの基礎を学習します。
複数のリクエストを公平に処理するアービトレーションは、システム設計において重要です。

## 学習の推奨順序

### 1. Hardware Scheduler (Round-Robin) (hw_scheduler/)
- **概要**: 4リクエストのラウンドロビンスケジューリング
- **学習内容**: アービトレーション、循環優先度管理、リクエスト/グラント
- **ファイル**: `hw_scheduler/hw_scheduler.sv`, `hw_scheduler/hw_scheduler_tb.sv`

## 参考資料

- Computer Architecture - Hennessy & Patterson
- IEEE 1800-2017 SystemVerilog LRM
