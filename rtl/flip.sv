module flip
( input  var       clk
, output var       ledr
, output var       ledg
, output var       ledb
);

logic [31:0] counter;

always_ff @(posedge clk)
  counter <= counter + 1;

assign {ledr, ledg, ledb} = ~counter[27:25];

endmodule
