`default_nettype none

module dacAttenuation
( input  var       i_clk48   // Runs at 48MHz
, input  var       i_rst48_n // Active low reset for sys_clk
, input  var       i_valid   // Only update DAC volume when CSRStorage is written to
, input  var [7:0] i_atten   // 8-bit attenuation control (0x00 = min, 0xFF = max)
, output var       o_sel_n   // DAC Control bus select (active low)
, output var       o_clock   // DAC Control bus clock
, output var       o_data    // DAC Control bus data (serial)
);

logic [7:0] valid;
always_ff @(posedge i_clk48) // Capture when CSTStorage is written to
  if (!i_rst48_n)   valid <= 8'h00;
  else if (i_valid) valid <= 8'hFF;
  else              valid <= {valid[6:0], 1'b0};

logic [7:0] volume;
always_ff @(posedge i_clk48) // Update volume setting when CSRStorage is written to
  if (!i_rst48_n)   volume <= 8'h00;
  else if (i_valid) volume <= i_atten;

logic [2:0] div_6m;
always_ff @(posedge i_clk48) // Count 6MHz cycle
  if (!i_rst48_n) div_6m <= 3'b000;
  else            div_6m <= div_6m + 1;

always_comb o_clock = div_6m[2]; // Drive DAC Control bus clock at 6MHz

logic [34:0] sel_n;
always_ff @(negedge o_clock) // Update SEL_n on falling edge of CLOCK (As in PCM1780 Datasheet)
  if (!i_rst48_n)    {o_sel_n, sel_n} <= 36'hFFFFFFFFF;
  else if (valid[7]) {o_sel_n, sel_n} <= 36'h0000C0003;
  else               {o_sel_n, sel_n} <= {sel_n, 1'b1};

logic [34:0] data;
always_ff @(negedge o_clock) // Update DATA on falling edge of CLOCK (As in PCM1780 Datasheet)
  if (!i_rst48_n)    {o_data, data} <= 36'h000000000;
  else if (valid[7]) {o_data, data} <= {8'd16, volume, 2'd0, 8'd17, volume, 2'd0};
  else               {o_data, data} <= {data, 1'b0};

endmodule
