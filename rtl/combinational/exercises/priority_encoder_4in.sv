// Module: priority_encoder_4in
// Description: 4入力のpriority encoder。最上位ビットが最高優先度。

module priority_encoder_4in #(
  parameter NUM_INPUTS = 4
) (
  input logic [WIDTH-1:0] inputs,
  output logic [WIDTH/2-1:0] result,
  output logic valid
);
  always_comb begin
    valid = 1'b1;  // デフォルトでvalid

    unique casez (data_in)
      4'b1???: data_out = 2'b11;
      4'b01??: data_out = 2'b10;
      4'b001?: data_out = 2'b01;
      4'b0001: data_out = 2'b00;
      4'b0000: begin
        data_out = 2'b00;
        valid = 1'b0;
      end
    endcase
  end
       
  // always_comb begin
  //   valid = 1'b1;
  //
  //   if (data_in[3]) data_out = 2'b11;
  //   else if (data_in[2]) data_out = 2'b10;
  //   else if (data_in[1]) data_out = 2'b01;
  //   else if (data_in[0]) data_out = 2'b00;
  //   else begin
  //     valid = 1'b0;
  //     data_out = 2'b00;
  //   end
  // end
endmodule

