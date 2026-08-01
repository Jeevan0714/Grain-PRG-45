# ==============================================================================
# SDC Constraints for Open-Source 45nm Laptop Flow
# Target Frequency: 100 MHz (10.0 ns Period)
# ==============================================================================

create_clock -name clk -period 10.0 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

# Input & Output Delays (excluding clock port)
set_input_delay  0.5 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.5 -clock clk [all_outputs]
