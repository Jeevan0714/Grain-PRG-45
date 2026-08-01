# ==============================================================================
# SDC Constraints for SkyWater 130nm PDK Implementation
# Target Frequency: 50 MHz (20.0 ns Period)
# ==============================================================================

create_clock -name clk -period 20.0 [get_ports clk]
set_clock_uncertainty 0.25 [get_clocks clk]

# Input & Output Delays (excluding clock port)
set_input_delay  1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock clk [all_outputs]
