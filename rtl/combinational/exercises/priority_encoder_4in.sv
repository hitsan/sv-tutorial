module priority_encoder_4in #(
  parameter WIDTH = 4
) (
  input logic [WIDTH-1:0] data_in,
  output logic [WIDTH/2-1:0] data_out,
  output logic valid
);
  always_comb begin
    unique casez (data_in)
      4'b1???: data_out = 2'b11;
      4'b01??: data_out = 2'b10;
      4'b001?: data_out = 2'b01;
      4'b0001: data_out = 2'b00;
      4'b0000: begin
        data_out = 2'b00;
        valid = 0;
      end
    endcase
       
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

