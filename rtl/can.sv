`default_nettype none

module can
( input  var        i_clk
, input  var        i_rst_n
, input  var [10:0] i_id
, input  var [10:0] i_mask
, input  var        i_rx
, output var        o_tx
, output var [10:0] o_id
, output var [ 7:0] o_data0
, output var [ 7:0] o_data1
, output var [ 7:0] o_data2
, output var [ 7:0] o_data3
, output var [ 7:0] o_data4
, output var [ 7:0] o_data5
, output var [ 7:0] o_data6
, output var [ 7:0] o_data7
);

logic rx;
always_ff @(posedge i_clk) // Capture i_rx on rising edge of i_clk
  rx <= i_rx;

logic rx_p;
always_ff @(posedge i_clk) // Store previous value of i_rx
  rx_p <= rx;

logic rx_r;
always_comb rx_r = rx && !rx_p; // Detect rising edge of rx

logic [8:0] div_1m;
always_ff @(posedge i_clk)
  if (!i_rst_n)              div_1m <= 9'd0;       // Reset
  else if (rx_r)             div_1m <= 9'd1;       // Align to 1 -> 0 transition
  else if (div_1m == 9'd383) div_1m <= 9'd0;       // Wrap at 384
  else                       div_1m <= div_1m + 1; // Increment

logic bit_t_75;
always_ff @(posedge i_clk) bit_t_75 <= (div_1m == 9'd287); // 75% of bit time

logic eof;
logic stuff_bit;
logic [2:0] stuff_count;
logic [98:0] rx_shift;
always_ff @(posedge i_clk) // Store incoming bits in a shift register
  if (!i_rst_n || eof)             rx_shift <= '1; // Reset or End-of-Frame
  else if (bit_t_75 && !stuff_bit) rx_shift <= {rx_shift[97:0], rx};
    // Shift in next bit at 75% of bit time if not a stuff bit

always_comb stuff_bit = (stuff_count == 3'd4); // Detect bit stuffing

logic rx_prev;
always_ff @(posedge i_clk) if (bit_t_75) rx_prev <= rx;

always_ff @(posedge i_clk)
  if (!i_rst_n)                         stuff_count <= 3'd0;            // Reset
  else if (bit_t_75 && stuff_bit)       stuff_count <= 3'd0;            // Stuffed bit
  else if (bit_t_75 && (rx_prev == rx)) stuff_count <= stuff_count + 1; // Same bit, increment count
  else if (bit_t_75)                    stuff_count <= 3'd0;            // Different bit, reset count

logic [6:0] det_eof;
always_ff @(posedge i_clk)
  if (!i_rst_n)      det_eof <= 7'd0;               // Reset
  else if (bit_t_75) det_eof <= {det_eof[5:0], rx}; // Shift in next bit at 75% of bit time

always_ff @(posedge i_clk) eof <= &{det_eof}; // Detect EOF (7 consecutive recessive/1 bits)

// Break out rx_shift into individual signals
logic        b_sof;
logic [10:0] b_id;
logic        b_rtr;
logic        b_ide;
logic        b_r0;
logic [ 3:0] b_dlc;
logic [63:0] b_data;
logic [14:0] b_crc;
logic        b_crc_del;
always_comb b_sof     = rx_shift[98];
always_comb b_id      = rx_shift[97:87];
always_comb b_rtr     = rx_shift[86];
always_comb b_ide     = rx_shift[85];
always_comb b_r0      = rx_shift[84];
always_comb b_dlc     = rx_shift[83:80];
always_comb b_data    = rx_shift[79:16];
always_comb b_crc     = rx_shift[15:1];
always_comb b_crc_del = rx_shift[0];

logic id_match;
always_ff @(posedge i_clk) id_match <= ((i_id & i_mask) == (b_id & i_mask)); // Check if CAN ID matches

logic dlc_match;
always_ff @(posedge i_clk) dlc_match <= (b_dlc == 4'd8); // Check if DLC is 8 (Hardcoded in Stacksynth)

logic crc_match;
always_ff @(posedge i_clk) crc_match <= 1'b1; // TODO: Implement CRC checking

logic msg_valid; // Check if message is valid
always_ff @(posedge i_clk) msg_valid <= &{id_match, !b_rtr, !b_ide, !b_r0, dlc_match, crc_match, b_crc_del};

always_ff @(posedge i_clk)
  if (!i_rst_n) o_tx <= 1'b1;                  // Reset
  else if (div_1m == 9'd1) o_tx <= !msg_valid; // Output dominant (0) if message valid, at start of bit time

always_ff @(posedge i_clk)
  if (!i_rst_n) o_id <= 11'd0;                        // Reset
  else if (div_1m == 9'd1 && msg_valid) o_id <= b_id; // Update received ID if valid, at start of bit time

logic [63:0] data;
always_ff @(posedge i_clk)
  if (!i_rst_n)                         data <= 64'd0;  // Reset
  else if (div_1m == 9'd1 && msg_valid) data <= b_data; // Update data if valid, at start of bit time

// Output data as individual bytes
always_comb o_data0 = data[63:56];
always_comb o_data1 = data[55:48];
always_comb o_data2 = data[47:40];
always_comb o_data3 = data[39:32];
always_comb o_data4 = data[31:24];
always_comb o_data5 = data[23:16];
always_comb o_data6 = data[15:8];
always_comb o_data7 = data[7:0];

endmodule

/* CRC Formula from BOSCH CAN Specification
crc_rg = '0; // Initialise shift register
repeat {
  crcnxt = nxtbit ^ crc_rg[14];
  crc_rg = {crc_rg[13:0], 1'b0}; // Shift left by 1
  if (crcnxt) crc_rg = crc_rg ^ 15'h4599; // XOR with 15'h4599
} until (input runs out)
*/
