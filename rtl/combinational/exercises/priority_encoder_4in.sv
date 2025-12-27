// Greg Stitt
// University of Florida

// Module: priority_encoder_4in
// Description: 4入力のpriority encoder。最上位ビットが最高優先度。
//              複数の実装方法を提供し、トップモジュールで切り替え可能。

// Module: priority_encoder_4in_if
// Description: if-else文による実装

module priority_encoder_4in_if #(
  parameter int NUM_INPUTS = 4,
  localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS)
) (
  input  logic [NUM_INPUTS-1:0] inputs,
  output logic [NUM_OUTPUTS-1:0] result,
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


// Module: priority_encoder_4in_case_unique
// Description: unique casez文による実装

module priority_encoder_4in_case_unique #(
  parameter int NUM_INPUTS = 4,
  localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS)
) (
  input  logic [NUM_INPUTS-1:0] inputs,
  output logic [NUM_OUTPUTS-1:0] result,
  output logic valid
);
  always_comb begin
    valid = 1'b1;

    unique casez (inputs)
      4'b1???: result = 2'b11;
      4'b01??: result = 2'b10;
      4'b001?: result = 2'b01;
      4'b0001: result = 2'b00;
      4'b0000: begin
        result = 2'b00;
        valid = 1'b0;
      end
    endcase
  end
endmodule  // priority_encoder_4in_case_unique


// Module: priority_encoder_4in
// Description: トップモジュール。コメントアウトで実装を切り替え。

module priority_encoder_4in #(
  parameter int NUM_INPUTS = 4,
  localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS)
) (
  input  logic [NUM_INPUTS-1:0] inputs,
  output logic [NUM_OUTPUTS-1:0] result,
  output logic valid
);
  // Uncomment the desired implementation
  priority_encoder_4in_case_unique #(.NUM_INPUTS(NUM_INPUTS)) pe (.*);
  //priority_encoder_4in_if #(.NUM_INPUTS(NUM_INPUTS)) pe (.*);
endmodule  // priority_encoder_4in
