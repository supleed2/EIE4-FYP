`default_nettype none

module dacDriver
( input  var        i_clk36   // Runs at 36.864MHz (48k * 768)
, input  var        i_rst36_n
, input  var        i_wait    // don't retrieve new packet if high
, input  var [47:0] i_lraudio // Received at 48kHz, capture when o_rdreq high
, output var        o_rdreq   // Pulse 1 cycle at 36.864MHz if i_wait low
, output var        o_lrck    // Runs at 48kHz (i_clk36 / 768), changes on falling edge of o_bck
, output var        o_bck     // Runs at 2.304MHz (48k * 48, i_clk36 / 16)
, output var        o_data    // Changes on falling edge of o_bck
);

logic [8:0] div_48k;
always_ff @(posedge i_clk36) // Count half 48kHz cycle
  if (!i_rst36_n)             div_48k <= 0;
  else if (div_48k == 9'd384) div_48k <= 0;
  else                        div_48k <= div_48k + 1;

logic clk_48k;
always_ff @(posedge i_clk36) // Generate 48kHz clock
  if (!i_rst36_n)             clk_48k <= 0;
  else if (div_48k == 9'd384) clk_48k <= ~clk_48k;

logic clk_48k_past;
always_ff @(posedge i_clk36) // Track rising of 48kHz clock
  clk_48k_past <= clk_48k;

logic [3:0] div_bck;
always_ff @(posedge i_clk36) // Count half 2.304MHz cycle
  if (!i_rst36_n)           div_bck <= 0;
  else if (div_bck == 4'd8) div_bck <= 0;
  else                      div_bck <= div_bck + 1;

always_ff @(posedge i_clk36) // Generate 2.304MHz clock
  if (!i_rst36_n)           o_bck <= 0;
  else if (div_bck == 4'd8) o_bck <= ~o_bck;

always_ff @(posedge i_clk36) // Pulse Read Request on rising edge of clk_48k if i_wait low
  if (!i_rst36_n)                               o_rdreq <= 0;
  else if (!i_wait && clk_48k && !clk_48k_past) o_rdreq <= 1;
  else                                          o_rdreq <= 0;

logic [47:0] lraudio;
always_ff @(posedge i_clk36) // Capture new audio sample on Read Request
  if (!i_rst36_n)                               lraudio <= '0;
  else if (!i_wait && clk_48k && !clk_48k_past) lraudio <= i_lraudio;

always_ff @(negedge o_bck) // Update LRCK on falling edge of BCK (As in PCM1780 Datasheet)
  if (!i_rst36_n) o_lrck <= 0;
  else            o_lrck <= clk_48k;

logic [23:0] audio_buf;
always_ff @(negedge o_bck) // Update DATA on falling edge of BCK (As in PCM1780 Datasheet)
  if (!i_rst36_n)                    {o_data, audio_buf} <= {25{1'b0}};             // Reset to all 0s
  else if (clk_48k && !clk_48k_past) {o_data, audio_buf} <= {lraudio[47:24], 1'b0}; // Load left sample into shifted output
  else if (!clk_48k && clk_48k_past) {o_data, audio_buf} <= {lraudio[23:0], 1'b0};  // Load right sample into shifted output
  else                               {o_data, audio_buf} <= {audio_buf, 1'b0};      // Shift loaded sample into o_data

endmodule
