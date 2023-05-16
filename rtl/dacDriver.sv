`default_nettype none

module dacDriver
( input  var        i_clk36   // Runs at 36.864MHz (48k * 768)
, input  var        i_rst36_n // Active low reset for dac_clk
, input  var        i_wait    // don't retrieve new packet if high
, input  var [15:0] i_sample  // 16-bit sample to output
, output var        o_rdreq   // Pulse 1 cycle at 36.864MHz if i_wait low
, output var        o_lrck    // Runs at 48kHz (i_clk36 / 768), changes on falling edge of o_bck
, output var        o_bck     // Runs at 2.304MHz (48k * 48, i_clk36 / 16)
, output var        o_data    // Changes on falling edge of o_bck
);

logic [8:0] div_48k;
always_ff @(posedge i_clk36) // Count half 48kHz cycle
  if (!i_rst36_n)             div_48k <= 0;
  else if (div_48k == 9'd383) div_48k <= 0;
  else                        div_48k <= div_48k + 1;

logic clk_48k;
always_ff @(posedge i_clk36) // Generate 48kHz clock
  if (!i_rst36_n)             clk_48k <= 0;
  else if (div_48k == 9'd0) clk_48k <= ~clk_48k;

logic clk_48k_mid;
always_ff @(negedge o_bck) // Track rising / falling edge of 48kHz clock (part 1)
  clk_48k_mid <= clk_48k;

logic clk_48k_past;
always_ff @(posedge o_bck) // Track rising / falling edge of 48kHz clock (part 2)
  clk_48k_past <= clk_48k_mid;

always_ff @(posedge i_clk36) // Generate 2.304MHz clock
  if (!i_rst36_n)                o_bck <= 0;
  else if (div_48k[2:0] == 3'd0) o_bck <= ~o_bck;

always_ff @(posedge i_clk36) // Pulse Read Request on rising edge of 48kHz clock if i_wait low
  if (!i_rst36_n)                               o_rdreq <= 0;
  else if (!i_wait && clk_48k && !clk_48k_past) o_rdreq <= 1;
  else                                          o_rdreq <= 0;

logic [15:0] sample;
always_ff @(posedge i_clk36) // Capture new audio sample on Read Request
  if (!i_rst36_n)                               sample <= '0;
  else if (!i_wait && clk_48k && !clk_48k_past) sample <= i_sample;

always_ff @(negedge o_bck) // Update LRCK on falling edge of BCK (As in PCM1780 Datasheet)
  if (!i_rst36_n) o_lrck <= 0;
  else            o_lrck <= clk_48k;

logic [15:0] audio_buf;
always_ff @(negedge o_bck) // Update DATA on falling edge of BCK (As in PCM1780 Datasheet)
  if (!i_rst36_n)                    {o_data, audio_buf} <= {25{1'b0}};        // Reset to all 0s
  else if (clk_48k && !clk_48k_past) {o_data, audio_buf} <= {sample, 1'b0};    // Load sample (L) into shifted output
  else if (!clk_48k && clk_48k_past) {o_data, audio_buf} <= {sample, 1'b0};    // Load sample (R) into shifted output
  else                               {o_data, audio_buf} <= {audio_buf, 1'b0}; // Shift loaded sample into o_data

endmodule
