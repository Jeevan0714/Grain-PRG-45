# ==============================================================================
# Standard Synopsys Design Constraints (SDC) for Cadence Genus / Innovus
# Target Frequency: 100 MHz (10.0 ns Period)
# ==============================================================================

# 1. Define Primary Clock (100 MHz)
create_clock -name clk -period 10.0 [get_ports clk]

# 2. Set Clock Uncertainty & Jitter
set_clock_uncertainty 0.2 [get_clocks clk]

# 3. Set Input and Output Delays (5% of clock period)
set_input_delay  0.5 -clock clk [all_inputs]
set_output_delay 0.5 -clock clk [all_outputs]

# 4. Set Driving Cell & Load Constraints
set_driving_cell -lib_cell BUF_X1 [all_inputs]
set_load 0.05 [all_outputs]