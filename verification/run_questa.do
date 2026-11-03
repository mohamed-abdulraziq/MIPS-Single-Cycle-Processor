# Run from the repository root in QuestaSim / ModelSim
vlib work
vlog -sv rtl/ALSU.sv rtl/MUX.sv rtl/sign_extend.sv \
     rtl/PC_cntrl.sv rtl/PC_plus4.sv rtl/Reg_file.sv \
     rtl/Data_mem.sv rtl/instruction_mem.sv \
     rtl/control_unit.sv rtl/MIPI_Single_cyc_top.sv \
     verification/tb_MIPS_top.sv
vsim -c tb_MIPS_extensive -do "run -all; quit -f"
