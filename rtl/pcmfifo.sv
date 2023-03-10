////////////////////////////////////////////////////////////////////////////////
//
// The Verilog logic in this module is based on the paper by Clifford E.
// Cummings, of Sunburst Design, Inc, titled: "Simulation and Synthesis
// Techniques for Asynchronous FIFO Design". This paper may be found at
// http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf.
//
// Minor edits to that logic have been made by Gisselquist Technology, LLC.
// Gisselquist Technology, LLC, asserts no copywrite or ownership of these
// minor edits. The edited Verilog file can be found at
// https://github.com/ZipCPU/website/blob/master/examples/afifo.v, which also
// contains many properties (Licensed under GPL, found at
// https://www.gnu.org/licenses/#GPL) for use in Formal Verification. Those
// properties have been removed in this module.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype  none

module pcmfifo
#(parameter int DW = 2
, parameter int AW = 4
)(input  var          i_clk48
, input  var          i_rst48_n
, input  var          i_dvalid
, input  var [DW-1:0] i_din
, output var          o_full
// ^ 48MHz Domain, v 36MHz Domain
, input  var          i_clk36
, input  var          i_rst36_n
, input  var          i_rdreq
, output var [DW-1:0] o_dout
, output var          o_empty
);

logic [AW-1:0] w_addr;
logic          w_full_next;
logic [AW  :0] w_ptr;
logic [AW  :0] w_ptr_next;
logic [AW  :0] w_ptr_grey;
logic [AW  :0] w_ptr_grey_buf1;
logic [AW  :0] w_ptr_grey_buf2;
logic [AW  :0] w_ptr_grey_next;

logic [AW-1:0] r_addr;
logic          r_empty_next;
logic [AW  :0] r_ptr;
logic [AW  :0] r_ptr_next;
logic [AW  :0] r_ptr_grey;
logic [AW  :0] r_ptr_grey_buf1;
logic [AW  :0] r_ptr_grey_buf2;
logic [AW  :0] r_ptr_grey_next;

logic [DW-1:0] mem [0:((1 << AW)-1)];

// Cross read Grey pointer to Write Domain (48MHz)
always_ff @(posedge i_clk48, negedge i_rst48_n)
  if (!i_rst48_n) {r_ptr_grey_buf2, r_ptr_grey_buf1} <= '0;
  else            {r_ptr_grey_buf2, r_ptr_grey_buf1} <= {r_ptr_grey_buf1, r_ptr_grey};

// Calculate next write addr
assign w_addr = w_ptr[AW-1:0];

// Calculate next write graycode
assign w_ptr_next  = w_ptr + { {(AW){1'b0}}, ((i_dvalid) && (!o_full)) };
assign w_ptr_grey_next = (w_ptr_next >> 1) ^ w_ptr_next;

// Register write addr and write graycode
always_ff @(posedge i_clk48, negedge i_rst48_n)
  if (!i_rst48_n) {w_ptr, w_ptr_grey} <= 0;
  else            {w_ptr, w_ptr_grey} <= {w_ptr_next, w_ptr_grey_next};

// Update whether fifo is full on next clock
assign w_full_next = (w_ptr_grey_next == {~r_ptr_grey_buf2[AW:AW-1], r_ptr_grey_buf2[AW-2:0] });
always_ff @(posedge i_clk48, negedge i_rst48_n)
  if (!i_rst48_n) o_full <= 1'b0;
  else            o_full <= w_full_next;

// Write to FIFO on Write Domain (48MHz) clock
always_ff @(posedge i_clk48)
  if ((i_dvalid) && (!o_full)) mem[w_addr] <= i_din;

// Cross write Grey pointer to Read Domain (36MHz)
always_ff @(posedge i_clk36, negedge i_rst36_n)
  if (!i_rst36_n) {w_ptr_grey_buf2, w_ptr_grey_buf1} <= 0;
  else            {w_ptr_grey_buf2, w_ptr_grey_buf1} <= {w_ptr_grey_buf1, w_ptr_grey};

// Calculate next read address
assign r_addr = r_ptr[AW-1:0];

// Calculate next read graycode
assign r_ptr_next  = r_ptr + { {(AW){1'b0}}, ((i_rdreq) && (!o_empty)) };
assign r_ptr_grey_next = (r_ptr_next >> 1) ^ r_ptr_next;

// Register read addr and read graycode
always_ff @(posedge i_clk36, negedge i_rst36_n)
  if (!i_rst36_n) {r_ptr, r_ptr_grey} <= 0;
  else            {r_ptr, r_ptr_grey} <= {r_ptr_next, r_ptr_grey_next};

// Update whether fifo is empty on next clock
assign r_empty_next = (r_ptr_grey_next == w_ptr_grey_buf2);
always_ff @(posedge i_clk36, negedge i_rst36_n)
  if (!i_rst36_n) o_empty <= 1'b1;
  else            o_empty <= r_empty_next;

// Output read data combinatorially
assign o_dout = mem[r_addr];

endmodule