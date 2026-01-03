// Greg Stitt
// University of Florida

// Module: priority_encoder
// Description: パラメータ化されたpriority encoder。
//              NUM_INPUTSパラメータで任意の入力数に対応。
//              forループによる汎用的な実装。

`timescale 1ns / 100ps

module priority_encoder #(
  parameter int NUM_INPUTS = 4,
  localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS)
) (
  input  logic [NUM_INPUTS-1:0] inputs,
  output logic [NUM_OUTPUTS-1:0] result,
  output logic valid
);
  always_comb begin
    result = '0;
    valid = 1'b0;
    for(int i = 0; i < NUM_INPUTS; i++) begin
      if (inputs[i]) begin
        result = i[NUM_OUTPUTS-1:0];
        valid = 1'b1;
      end
    end
  end
endmodule  // priority_encoder
