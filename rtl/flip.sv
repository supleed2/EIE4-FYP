`default_nettype none

module flip
( input  var i_clk
, output var o_ledr
, output var o_ledg
, output var o_ledb
);

logic [31:0] counter;
logic [2:0] leds;

always_ff @(posedge i_clk)
  if (counter > 32'd192_000_000) counter <= '0;
  else counter <= counter + 1;

always_comb
  if (counter < 24_000_000) {leds} = 3'b000;
  else if (counter < 48_000_000) {leds} = 3'b001;
  else if (counter < 72_000_000) {leds} = 3'b010;
  else if (counter < 96_000_000) {leds} = 3'b011;
  else if (counter < 120_000_000) {leds} = 3'b100;
  else if (counter < 144_000_000) {leds} = 3'b101;
  else if (counter < 168_000_000) {leds} = 3'b110;
  else {leds} = 3'b111;

always_comb {o_ledr, o_ledg, o_ledb} = leds;

endmodule
