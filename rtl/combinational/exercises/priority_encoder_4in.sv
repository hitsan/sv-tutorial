module priority_encoder_4in #(
  parameter WIDTH = 4
) (
  input logic [WIDTH-1:0] data_in,
  output logic [WIDTH/2-1:0] data_out
);
  always_comb begin
    if (data_in[3]) data_out = 2'b11;
    else if (data_in[2]) data_out = 2'b10;
    else if (data_in[1]) data_out = 2'b01;
    else if (data_in[0]) data_out = 2'b00;
    else data_out = 2'b00;
  end
endmodule
