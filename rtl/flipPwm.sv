`default_nettype none

module flipPwm
( input  var        clk
, input  var [23:0] rgb
, output var        ledr
, output var        ledg
, output var        ledb
);

logic [7:0] counter;

always_ff @(posedge clk)
  counter <= counter + 1;

assign ledr = (rgb[23:16] > counter);
assign ledg = (rgb[15: 8] > counter);
assign ledb = (rgb[ 7: 0] > counter);

endmodule
