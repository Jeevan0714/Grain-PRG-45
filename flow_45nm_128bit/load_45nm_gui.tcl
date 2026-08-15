# OpenROAD TCL script to display 45nm NanGate layout in GUI
read_lef /home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary.tech.lef
read_lef /home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef
read_def flow_45nm_128bit/results/lfsr_nfsr_top_45nm.def
gui::show
