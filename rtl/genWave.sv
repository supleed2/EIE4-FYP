`default_nettype none

module genWave
( input  var        i_clk48    // 48MHz clock
, input  var        i_rst48_n  // Active low reset
, input  var        i_pause    // Pause sample generation (backpressure)
, input  var [ 5:0] i_osc_sel  // Oscillator select, to update target freq / waveform
, input  var [23:0] i_t_freq   // Target frequency for selected oscillator
, input  var        i_tf_valid // Target frequency valid pulse (i_osc_sel must be set first)
, input  var [ 7:0] i_wav_sel  // Waveform select for selected oscillator
, input  var        i_ws_valid // Waveform select valid pulse (i_osc_sel must be set first)
, output var [15:0] o_sample   // Output sample data (mono)
, output var        o_pulse    // Output sample valid pulse
);

// 48kHz Clock Generation ##########################################################################

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

// Per Oscillator Settings Capture #################################################################

logic [23:0] t_freq [0:63];
always_ff @(posedge i_clk48)
  if (i_tf_valid) t_freq[i_osc_sel] <= i_t_freq; // Capture target frequency

logic [7:0] wav_sel [0:63];
always_ff @(posedge i_clk48)
  if (i_ws_valid) wav_sel[i_osc_sel] <= i_wav_sel; // Capture waveform select

// Per Oscillator Phase Step Generation ############################################################

logic [5:0] ps_clk;
always_ff @(posedge i_clk48) // Count to 64 at 48MHz
  if (!i_rst48_n) ps_clk <= '0;         // Reset
  else            ps_clk <= ps_clk + 1; // Increment

logic [23:0] int_phase_step; // Phase step calc from target frequency
always_comb int_phase_step = (24'd699 * t_freq[ps_clk]); // 699 = (2^24 / 48000) * 2 (Approximately)

logic [15:0] phase_step [0:63]; // Shift step right correctly (2^9)
always_ff @(posedge i_clk48) phase_step[ps_clk] <= {1'b0, int_phase_step[23:9]};

// Per Oscillator Phase Generation #################################################################

logic [15:0] phase [0:63];
for (genvar i = 0; i < 64; i++) begin: l_gen_phase
  always_ff @(posedge clk_48k) // Generate new phase sample on rising edge of 48kHz clock
    if (!i_rst48_n)                  phase[i] <= 16'd0;                    // Reset saw
    else if (phase_step[i] == 16'd0) phase[i] <= phase[i] >> 1;            // Divide by 2 if phase_step is 0
    else if (!i_pause)               phase[i] <= phase[i] + phase_step[i]; // Add phase_step if not paused (48kHz)
end

// Per Oscillator Sample Generation ################################################################

logic [15:0] saw;
always_ff @(posedge i_clk48) if (clk_div[1:0] == 2'd0) saw <= phase[clk_div[7:2]]; // Load saw to calculate sample for

logic [15:0] square;
always_ff @(posedge i_clk48) square <= {~saw[15], {15{saw[15]}}}; // Square wave is MSB of saw

logic [15:0] triangle;
always_ff @(posedge i_clk48) triangle <= saw[15] ? {saw[14], ~saw[13:0], 1'b1} : {~saw[14], saw[13:0], 1'b0}; // Triangle wave calculation

logic [15:0] sine;
saw2sin m_saw2sin // Sine wave calculation
( .i_clk(i_clk48)
, .i_saw(saw)
, .o_sin(sine)
);

logic [15:0] sample;
always_comb // Select waveform sample based on wav_sel
  case (wav_sel[clk_div[7:2]])
    8'd0: sample = saw;      // Saw wave
    8'd1: sample = square;   // Square wave
    8'd2: sample = triangle; // Triangle wave
    8'd3: sample = sine;     // Sine wave
    default: sample = saw;   // Default to phase wave
  endcase


logic osc_valid;
always_comb osc_valid = (clk_div < 9'd256); // 64 oscillators * 4 stages = 256 cycles

logic [15:0] samples [0:63]; // Store samples per oscillator
always_ff @(posedge i_clk48) if ((clk_div[1:0] == 2'd3) && osc_valid) samples[clk_div[7:2]] <= sample;

// Combine Samples into Single Sample ##############################################################

logic [23:0] samples_long [0:63]; // Sum all samples to get final output sample
always_comb samples_long[0] = {{8{samples[0][15]}}, samples[0]};
for (genvar i = 1; i < 64; i++) begin: l_gen_sample_long
  always_comb samples_long[i] = samples_long[i-1] + {{8{samples[i][15]}}, samples[i]};
end

logic [6:0] waves_count [0:63];
always_comb waves_count[0] = (phase[0] != 16'd0);
for (genvar i = 1; i < 64; i++) begin: l_gen_waves_count
  always_comb waves_count[i] = waves_count[i-1] + (phase[i] != 16'd0); // Count non-zeroes
end

logic [6:0] wv_cnt_1;
always_comb wv_cnt_1 = waves_count[63] - 1; // Subtract 1 from wave count

logic [2:0] shift; // Calculate shift amount
always_comb shift = wv_cnt_1[6] ? 3'd7
                  : wv_cnt_1[5] ? 3'd6
                  : wv_cnt_1[4] ? 3'd5
                  : wv_cnt_1[3] ? 3'd4
                  : wv_cnt_1[2] ? 3'd3
                  : wv_cnt_1[1] ? 3'd2
                  : wv_cnt_1[0] ? 3'd1
                  : 3'd0;

logic [23:0] samples_sum;
always_comb samples_sum = samples_long[63] >> shift; // Shift output sample right to get normalised output

always_comb o_sample = samples_sum[15:0];    // Output sample is 16 bits

endmodule
