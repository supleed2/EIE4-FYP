// CORDIC_par_seq.v   Core ALU of a CORDIC rotator,
//                    word-sequential implementation
//
// Revision information:
// 0.0  07-Jan-2004  Jonathan Bromley
//   Initial coding of word-sequential version
// 0.1  08-Jan-2004  Jonathan Bromley
//   Still using Verilog-1995 (will migrate to SV3.1 later);
//   added angle output and mode-control input, so that it
//   can be used to do Cartesian-to-polar conversion as well
//   as rotation
// 1.0  15-Jan-2004  Jonathan Bromley
//   Migrated everything to signed typedefs (SV3.1)
//   and signed arithmetic (see file ../common/defs.v)
// 1.1  25-Jan-2004  Jonathan Bromley
//   Improved internal documentation
// __________________________________________________________________________



// _________________________________________________________ DEPENDENCIES ___
//
// This module assumes the existence of a typedef T_sdata representing
// signed data.  This typedef should be a packed logic or integer.
// The code here will not work correctly if T_sdata, padded with the
// number of additional low-order bits specified by parameter guard_bits,
// is wider than 32 bits - in other words, we require that
//     $bits(T_sdata) + guard_bits <= 32
// __________________________________________________________________________



//___________________________________________________________ DESCRIPTION ___
//
// -------
// PURPOSE
// -------
//
// This module implements the CORDIC two-dimensional rotator algorithm
// originally proposed by Volder (1959).  It can be used to calculate
// trigonometrical functions sin, cos, arctan and others; it can also
// perform polar-to-rectangular and rectangular-to-polar conversion.
//
//
// ----------
// PARAMETERS
// ----------
//
// Two parameters, guardBits and stepBits, determine the internal
// behaviour of the CORDIC algorithm.
//
// stepBits is the number of bits in the counter that controls
// iteration of the CORDIC algorithm.  In the present implementation
// there will be exactly (2^stepBits) iterations - for example, 16
// iterations if stepBits=4.  As a guideline, (2^stepBits) should be
// at least as large as the number of bits in the data words.
//
// guardBits is the number of additional LSBs that is maintained in
// the internal arithmetic to improve precision.  It should normally
// be equal to stepBits, or at least (stepBits-1); otherwise, the
// additional precision gained by additional iterations of the CORDIC
// algorithm will be lost through rounding errors.  On the other hand,
// there is little to be gained from making guardBits greater than
// (stepBits+1).
//
// ------------------
// INPUTS AND OUTPUTS
// ------------------
//
// There is a single mode control input:
//   reduceNotRotate.....sets operating mode of the rotator for the
//                       next operation - see OPERATION below for details
//
// There are three datapath inputs:
//   angleIn.......2s complement signed value, the desired angle of
//                 rotation
//   xIn, yIn......Cartesian coordinates of the point being rotated,
//                 as 2s complement signed values
//
// There are three datapath outputs:
//   angleOut......2s complement signed value, the resulting angle
//                 after rotation
//   xOut, yOut....Cartesian coordinates of the rotated point,
//                 as 2s complement signed values
//
// There are two operation-control or handshake signals:
//   start.........input, should be asserted for one clock at a time when
//                 valid data are presented to the datapath inputs
//   ready.........output, held asserted when datapath outputs carry a
//                 valid calculation result
//
// The remaining inputs (clock, reset) are the usual positive-edge clock
// and asynchronous power-up reset.
//
//
// ---------
// OPERATION
// ---------
//
// Mode bit "reduceNotRotate" is sampled together with the datapath
// inputs whenever "start" is asserted.
//
// If reduceNotRotate is set (1), angleIn is ignored and the
// CORDIC rotator will rotate the x,y vector so that its y component
// is zero; thus, its x component will reflect the original vector's
// magnitude (scaled by the CORDIC gain) and the angle output will
// be equal to the original vector's argument.  This mode provides
// rectangular-to-polar conversion, and calculation of arctangent.
// If the yOut output is significantly different from zero at the end
// of the calculation, it indicates that the argument (angle) of the
// input vector was too far from zero for the CORDIC algorithm to be
// able to reduce it.
//
// If reduceNotRotate is clear (0), the CORDIC rotator will rotate the
// x,y input vector by the angle specified as angleIn (and scale it
// by the CORDIC gain); the output angle will then be close to zero.
// This mode provides polar-to-rectangular conversion, and calculation
// of sine and cosine.  If the angleOut output is significantly different
// from zero at the end of the calculation, it indicates that the required
// rotation angle was too large for the CORDIC algorithm to process.
//
// On receipt of a "start" input, the CORDIC processor abandons any
// calculation that may be in progress, clears the "ready" output to zero,
// and starts work on the new input values.  When finished, it sets
// "ready" to 1. Whenever "ready" is set, the data outputs
// xOut, yOut, angleOut are valid.  These outputs will remain valid,
// and "ready" will remain asserted, until "start" is asserted again at
// some future time.
//
//
// ---------------------------
// MATHEMATICAL CONSIDERATIONS
// ---------------------------
//
// CORDIC gain
// -----------
//
// It is an inevitable side-effect of the CORDIC algorithm that the
// rotated x,y coordinates are magnified by the CORDIC gain.  This
// gain is the product
//
//     N-1
//      P (cos(atn(2^(-i))))
//     i=0
//
// where N is the number of iterations of the CORDIC loop.
// The limit of this product as N tends to infinity is 1.646760258,
// and it approaches this limit quite quickly as N rises - for
// example, its value for N=4 is 1.642484066.  For any
// practically useful value of N, it is reasonable to use the limit.
//
// This hardware implementation makes no attempt to account for the
// CORDIC gain, and assumes that this gain factor will be compensated-for
// somewhere else in the system.
//
// Numerical overflow
// ------------------
//
// The output x,y values from the algorithm can be larger in magnitude than
// the larger of the two (x,y) inputs.  For example, if xIn and yIn are
// equal, and the corresponding point is then rotated by pi/4 (45 degrees),
// one of the output coordinates will be zero and the other will be sqrt(2)
// larger than either input.  Additionally, the outputs are scaled by the
// CORDIC gain as described above.  Consequently, if the largest possible
// input coordinate value is M, then the largest possible output is
// just under 2.33*M.  No account is taken of this effect in the hardware;
// input and output values have the same number of bits.  It is the user's
// responsibility to ensure that input values do not exceed 1/2.33 times
// the full-scale value - this sets a limit of  +/-14106 for 16-bit data.
//
// Scaling of data values
// ----------------------
//
// Scaling of the Cartesian coordinates is unimportant, except to note
// that the largest magnitude of output results can be as much as
// 2.33 times greater than largest the magnitude of the input, as
// described in "Numerical overflow" above.
//
// Scaling of angles is also quite flexible;  any scaling
// can be accommodated, provided the arctan values also have the
// same scaling.  Since the CORDIC rotator can rotate its input vector
// by more than one quadrant (pi/2) in either direction, it is
// reasonable and convenient to choose a scaling in which the
// angle is a 2s complement number, with its largest positive value
// (01111...1111) representing just less than +pi and its most
// negative value (10000..0000) representing exactly -pi.
// It is not possible to make effective use of the full range of these
// angles, since the CORDIC algorithm is incapable of rotating a vector
// by more than 1.743 radians (99.8 degrees) in either direction.
// __________________________________________________________________________




// This is a synthesisable design and doesn't need a `timescale,
// but we include one here to avoid any dependence on compilation order.
//
`timescale 1ns/1ns


//_________________________________________________ module CORDIC_par_seq ___

module CORDIC_par_seq
#( parameter
    stepBits  = 4,  // Must be enough to represent 0..angleBits-1
    guardBits = 4
 )
(
  input  logic clock,
  input  logic reset,

  input  logic start,
  output logic busy,

  input  logic reduceNotRotate,

  input  T_sdata angleIn,
  input  T_sdata xIn,
  input  T_sdata yIn,

  output T_sdata angleOut,
  output T_sdata xOut,
  output T_sdata yOut
);

  // Copy of reduceNotRotate taken at start time
  logic reduceMode;

  localparam sdata_width = $bits(T_sdata);

  typedef logic signed  [sdata_width+guardBits-1:0] T_acc;

  // Internal accumulators
  T_acc  x, y, angle;

  // Internal temporaries - output of combinational blocks
  T_acc arctan, scaleX, scaleY;
  logic clockwise;

  // Control and sequencing counter
  //
  logic [stepBits-1:0] step;


  // ____________________________________________ Combinational stuff ___

  // Factor-out common functionality:
  //
  // arctan(2^-n) lookup table
  assign arctan = atn(step);
  //
  // right-shifted coordinates
  assign scaleY = y >>> step;
  assign scaleX = x >>> step;
  //
  // convergence direction
  assign clockwise = reduceMode ?
                     // Yes?  Then we're trying to reduce y to zero:
                     // positive y means we should go clockwise.
                     (y >= 0):
                     // No?  Then we're reducing the angle to zero.
                     // Negative angle means we should go clockwise.
                     (angle < 0);

  // Create outputs
  //
  assign angleOut = angle >>> guardBits;
  assign xOut     =     x >>> guardBits;
  assign yOut     =     y >>> guardBits;

  // ___________________________________________________ Clocked logic ___
  //
  always @(posedge clock or posedge reset)

    if (reset) begin

      // dumb initialise
      //
      angle      <= 0;
      x          <= 0;
      y          <= 0;
      step       <= 0;
      busy       <= 0;
      reduceMode <= 0;

    end else if (start) begin

      // initialise, packing working registers with zero LSBs
      //
      x       <= xIn <<< guardBits;
      y       <= yIn <<< guardBits;
      step    <= 0;
      busy    <= 1;
      reduceMode <= reduceNotRotate;
      if (reduceNotRotate) begin
        angle <= 0;
      end else begin
        angle <= angleIn <<< guardBits;
      end

    end else if (busy) begin

      // do one iteration
      if (clockwise) begin

        // Angle is negative (or y is positive),
        //so we increase the angle and rotate clockwise
        angle <= angle + arctan;
        x     <= x     + scaleY;
        y     <= y     - scaleX;

      end else begin

        // Rotate counterclockwise
        angle <= angle - arctan;
        x     <= x     - scaleY;
        y     <= y     + scaleX;

      end // if (clockwise)... else...

      if (step == sdata_width-1) begin
        // All done at the end of this iteration
        busy <= 0;
      end // if (step == angleBits)

      step <= step + 1;

    end // if (start) ... else if (active) ...


    // __________________________________________________ function atn ___
    //
    // function atn provides a table of arctan(2^-n) to 32-bit precision,
    // and returns the result to the required precision.
    //
    function T_acc atn;
      input [stepBits-1:0] step;

      // internal working register
      integer a;

      begin

        // Lookup table.  Any unused LSBs will be thrown away
        // by synthesis, we hope!
        // There is surely no point in having more than 32 iterations?
        case (step)
           0: a = 536870912;  // atn(1) = pi/4 = 45 degrees = one octant
           1: a = 316933406;
           2: a = 167458907;
           3: a =  85004756;
           4: a =  42667331;
           5: a =  21354465;
           6: a =  10679838;
           7: a =   5340245;
           8: a =   2670163;
           9: a =   1335087;
          10: a =    667544;
          11: a =    333772;
          12: a =    166886;
          13: a =     83443;
          14: a =     41722;
          15: a =     20861;
          16: a =     10430;
          17: a =      5215;
          18: a =      2608;
          19: a =      1304;
          20: a =       652;
          21: a =       326;
          22: a =       163;
          23: a =        81;
          24: a =        41;
          25: a =        20;
          26: a =        10;
          27: a =         5;
          28: a =         3;
          29: a =         1;
          30: a =         1;
          31: a =         0;
          default:
              a =         0;
        endcase // step

        // Rescale result to match internal angle register (typedef T_acc)
        atn = a >>> ($bits(integer) - $bits(T_acc));

      end
    endfunction //atn

endmodule // CORDIC_par_seq
// _______________________________________________________________________
