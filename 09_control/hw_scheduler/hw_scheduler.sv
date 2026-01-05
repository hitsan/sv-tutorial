// Hardware Scheduler (Round-Robin) - 簡易版
module hw_scheduler #(
    parameter int NUM_REQUESTERS = 4
) (
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_REQUESTERS-1:0] request,
    output logic [NUM_REQUESTERS-1:0] grant
);
    // TODO: 優先度カウンタ
    // TODO: グラント生成
endmodule
