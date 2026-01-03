// Greg Stitt
// University of Florida

// Module: priority_encoder_4in_case
// Description: priority casez文による4入力priority encoderの実装
//              最上位ビットが最高優先度。

`timescale 1ns / 100ps

module priority_encoder_4in_case (
  input  logic [3:0] inputs,
  output logic [1:0] result,
  output logic valid
);
  always_comb begin
    valid = 1'b1;

    priority casez (inputs)
      4'b1???: result = 2'b11;
      4'b01??: result = 2'b10;
      4'b001?: result = 2'b01;
      4'b0001: result = 2'b00;
      default: begin
        result = 2'b00;
        valid = 1'b0;
      end
    endcase
  end
endmodule  // priority_encoder_4in_case
