`default_nettype none

module genSaw
( input  var        i_clk48
, input  var        i_rst48_n
, input  var        i_pause
, input  var [23:0] i_targetf
, input  var [ 7:0] i_wave
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

logic [15:0] saw;
always_ff @(posedge clk_48k) // Generate new saw sample on rising edge of 48kHz clock
  if (!i_rst48_n)    saw <= '0;
  else if (!i_pause) saw <= saw + saw_step; // Add saw_step if not paused (48kHz)

logic [15:0] square;
always_comb square = {~saw[15], {15{saw[15]}}}; // Square wave is MSB of saw

logic [15:0] triangle;
always_comb triangle = saw[15] ? {~saw[14:0], 1'b1} : {saw[14:0], 1'b0}; // Triangle wave calc

logic [15:0] sine;
always_comb sine = saw; // TODO: Insert sine calcuation here?

always_comb // Select output waveform
  case (i_wave[1:0])
    2'd0: o_sample = saw;
    2'd1: o_sample = square;
    2'd2: o_sample = triangle;
    2'd3: o_sample = sine;
  endcase

endmodule
