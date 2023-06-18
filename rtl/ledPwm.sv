`default_nettype none

module ledPwm
( input  var        clk
, input  var [23:0] rgb
, output var        ledr
, output var        ledg
, output var        ledb
);

logic [7:0] counter;

always_ff @(posedge clk)
  counter <= counter + 1;

always_comb ledr = (rgb[23:16] > counter);
always_comb ledg = (rgb[15: 8] > counter);
always_comb ledb = (rgb[ 7: 0] > counter);

endmodule
