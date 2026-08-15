# ==============================================================================
# SDC Constraints — Grain-128 LFSR-NFSR 128-bit (NanGate 45nm)
# Target Frequency : 100 MHz (10.0 ns period)
# ==============================================================================

create_clock -name clk -period 10.0 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

# Clean input/output port constraints compatible with OpenROAD
set_input_delay  0.5 -clock clk [get_ports {rst enable plaintext*}]
set_output_delay 0.5 -clock clk [get_ports {ciphertext* decrypted_text*}]
