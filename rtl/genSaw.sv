`default_nettype none

module genSaw
( input  var        i_clk48
, input  var        i_rst48_n
, input  var        i_pause
, input  var [23:0] i_targetf
, output var [15:0] o_sample
, output var        o_pulse
);

logic [8:0] clk_div;
always_ff @(posedge i_clk48) // Count half 48kHz cycle
  if (!i_rst48_n)             clk_div <= 0;
  else if (clk_div == 9'd499) clk_div <= 0;
  else                        clk_div <= clk_div + 1;

logic clk_48k;
always_ff @(posedge i_clk48) // Generate 48kHz clock
  if (!i_rst48_n)           clk_48k <= 0;
  else if (clk_div == 9'd0) clk_48k <= ~clk_48k;

logic clk_48k_past;
always_ff @(posedge i_clk48) // Track rising / falling edge of 48kHz clock
  clk_48k_past <= clk_48k;

always_comb o_pulse = clk_48k && !clk_48k_past; // Detect rising edge of 48kHz clock

logic [23:0] int_saw_step;
always_comb int_saw_step = (24'd699 * i_targetf); // Sawtooth step calc from input target freq

logic [15:0] saw_step;
always_comb saw_step = {1'b0, int_saw_step[23:9]}; // Shift step right correctly (2^9)

always_ff @(posedge clk_48k) // Generate new sample on rising edge of 48kHz clock
  if (!i_rst48_n)    o_sample <= '0;
  else if (!i_pause) o_sample <= o_sample + saw_step; // Add saw_step if not paused (48kHz)

endmodule
