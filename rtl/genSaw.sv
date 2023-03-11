`default_nettype none

module genSaw
( input  var        i_clk48
, input  var        i_rst48_n
, input  var        i_pause
, input  var [23:0] i_tf
, output var [47:0] o_lr
, output var        o_new_pulse
);

logic [8:0] clk_div;
always_ff @(posedge i_clk48)
  if (!i_rst48_n)             clk_div <= 0;
  else if (clk_div == 9'd500) clk_div <= 0;
  else                        clk_div <= clk_div + 1;

logic clk_48k;
always_ff @(posedge i_clk48)
  if (!i_rst48_n)             clk_48k <= 0;
  else if (clk_div == 9'd500) clk_48k <= ~clk_48k;

logic clk_48k_past;
always_ff @(posedge i_clk48)
  clk_48k_past <= clk_48k;

assign o_new_pulse = clk_48k && !clk_48k_past;

logic [23:0] saw_step;
assign saw_step = (24'd699 * i_tf) >> 1;

logic [23:0] waveform;
always_ff @(posedge clk_48k)
  if (!i_rst48_n)    waveform <= '0;
  else if (!i_pause) waveform <= waveform + saw_step;

assign o_lr = {waveform, waveform};

endmodule
