// 演習1: 基本的なモジュールインスタンス化
// 4:1マルチプレクサを2:1マルチプレクサから構成

/*
 * 要求仕様:
 * - 2:1マルチプレクサ3個を使って4:1マルチプレクサを実装
 * - ../combinational/examples/mux2x1.sv を使用
 *
 * 構造:
 *           ┌───────┐
 *    in[0]──┤       │
 *           │ MUX0  ├──┐
 *    in[1]──┤       │  │  ┌───────┐
 *           └───────┘  ├──┤       │
 *    sel[0]────────────┘  │       │
 *                         │ MUX2  ├── out
 *           ┌───────┐  ┌──┤       │
 *    in[2]──┤       │  │  └───────┘
 *           │ MUX1  ├──┘
 *    in[3]──┤       │
 *           └───────┘
 *    sel[0]────────────┘
 *    sel[1]──────────────────────┘
 */

module mux4x1_structural (
    input  logic [3:0] in,
    input  logic [1:0] sel,
    output logic       out
);
  logic out0;
  logic out1;
  mux2x1_assign mux0 (
      .in0(in[0]),
      .in1(in[1]),
      .sel(sel[0]),
      .out(out0)
  );

  mux2x1_assign mux1 (
      .in0(in[2]),
      .in1(in[3]),
      .sel(sel[0]),
      .out(out1)
  );

  mux2x1_assign mux2 (
      .in0(out0),
      .in1(out1),
      .sel(sel[1]),
      .out(out)
  );

endmodule : mux4x1_structural
