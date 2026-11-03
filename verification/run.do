# QuestaSim / ModelSim command script
# Run from the repository root: do verification/run.do
transcript file verification/questa_transcript.log
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
vlog -sv \
    rtl/ALSU.sv \
    rtl/MUX.sv \
    rtl/sign_extend.sv \
    rtl/PC_cntrl.sv \
    rtl/PC_plus4.sv \
    rtl/Reg_file.sv \
    rtl/Data_mem.sv \
    rtl/instruction_mem.sv \
    rtl/control_unit.sv \
    rtl/MIPI_Single_cyc_top.sv \
    verification/tb_MIPS_top.sv
vsim -c work.tb_MIPS_extensive
run -all
quit -f
