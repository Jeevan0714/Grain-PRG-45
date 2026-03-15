# 1. Read the Nangate 45nm standard cell library
read_liberty ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

# 2. Read your newly generated flattened netlist
read_verilog synth_netlist.v

# 3. Link the design to your top module
link_design lfsr_nfsr_top

# 4. Define constraints DIRECTLY here (100 MHz clock)
create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay  0.5 -clock clk [all_inputs]
set_output_delay 0.5 -clock clk [all_outputs]

# 5. Run the reports with clear formatting
puts "\n=================================="
puts "       SETUP TIMING REPORT"
puts "=================================="
report_checks -path_delay max -format full

puts "\n=================================="
puts "       HOLD TIMING REPORT"
puts "=================================="
report_checks -path_delay min -format full