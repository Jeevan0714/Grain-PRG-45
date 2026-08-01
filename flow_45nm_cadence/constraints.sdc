# ==============================================================================
# Standard SDC Constraints for Cadence 45nm Flow
# Target Frequency: 100 MHz (10.0 ns Period)
# ==============================================================================

create_clock -name clk -period 10.0 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

# Input & Output Delays (excluding clock port)
set_input_delay  0.5 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.5 -clock clk [all_outputs]

set_driving_cell -lib_cell BUF_X1 [remove_from_collection [all_inputs] [get_ports clk]]
set_load 0.05 [all_outputs]
