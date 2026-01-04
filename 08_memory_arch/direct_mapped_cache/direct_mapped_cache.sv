// Direct-Mapped Cache - 簡易版（4エントリ）
module direct_mapped_cache #(
    parameter int ADDR_WIDTH = 16,
    parameter int DATA_WIDTH = 32,
    parameter int CACHE_SIZE = 4
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [ADDR_WIDTH-1:0]  addr,
    input  logic                   read_enable,
    input  logic                   write_enable,
    input  logic [DATA_WIDTH-1:0]  write_data,
    output logic [DATA_WIDTH-1:0]  read_data,
    output logic                   hit,
    output logic                   miss
);
    // TODO: タグ、データ、validビットの配列
    // TODO: アドレス分解（tag, index）
    // TODO: ヒット/ミス判定
endmodule
