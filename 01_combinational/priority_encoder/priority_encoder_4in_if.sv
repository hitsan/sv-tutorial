// Greg Stitt
// University of Florida

// Module: priority_encoder_4in_if
// Description: if-else文による4入力priority encoderの実装
//              最上位ビットが最高優先度。

`timescale 1ns / 100ps

module priority_encoder_4in_if (
  input  logic [3:0] inputs,
  output logic [1:0] result,
  output logic valid
);
  always_comb begin
    valid = 1'b1;

    if (inputs[3]) result = 2'b11;
    else if (inputs[2]) result = 2'b10;
    else if (inputs[1]) result = 2'b01;
    else if (inputs[0]) result = 2'b00;
    else begin
      valid = 1'b0;
      result = 2'b00;
    end
  end
endmodule  // priority_encoder_4in_if
