#####################################################################
# Design Compiler synthesis script - MIPS Single-Cycle Processor
# Run from repository root:
#   dc_shell -f synthesis/syn_script_MIPS.tcl | tee synthesis/syn_MIPS.log
#####################################################################

# ------------------------- User settings -------------------------
set top_module   MIPI_Single_cyc_top
set CLK_PERIOD   100.0
set IMEM_DEPTH   256       ;# bytes: enough for 41 instructions (164 bytes)
set DMEM_DEPTH   64        ;# bytes: covers the tested data addresses
set USE_ULTRA    0         ;# 1 = compile_ultra, 0 = compile

# ------------------------- Directories --------------------------
define_design_lib work -path ./work
file mkdir synthesis/reports
file mkdir synthesis/results
set_svf synthesis/MIPS_SINGLE_CYC.svf

# ------------------------- Libraries ----------------------------
set LIB_DIR /home/IC/system_Me/std_cells
lappend search_path $LIB_DIR
lappend search_path .

set SSLIB scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db
set TTLIB scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db
set FFLIB scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db

set target_library [list $SSLIB]
set link_library   [list * $SSLIB $TTLIB $FFLIB]
set_min_library $SSLIB -min_version $FFLIB

# ------------------------- Read RTL -----------------------------
puts "================ Reading RTL ================"
set rtl_files [list \
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
]
analyze -format sverilog -library work $rtl_files

elaborate $top_module -library work \
    -parameters "IMEM_DEPTH=$IMEM_DEPTH,DMEM_DEPTH=$DMEM_DEPTH"

puts "Elaborated design: [get_object_name [current_design]]"

# ------------------------- Link and checks ----------------------
puts "================ Link / Check ================"
link
check_design > synthesis/reports/check_design_pre.rpt

# ------------------------- Constraints --------------------------
puts "================ Constraints ================="
source -echo ./synthesis/cons_MIPS.tcl

set data_inputs [remove_from_collection [all_inputs] \
                    [get_ports [list CLK rst_n]]]

group_path -name INREG -from $data_inputs -to [all_registers -data_pins]
group_path -name REGOUT -from [all_registers -output_pins] -to [all_outputs]
group_path -name INOUT -from $data_inputs -to [all_outputs]

# ------------------------- Compile ------------------------------
puts "================ Compile ====================="
if {$USE_ULTRA} {
    compile_ultra -no_autoungroup
} else {
    compile -map_effort high
}

# ------------------------- Write Netlist ------------------------
puts "================ Write Outputs ==============="
set_svf -off

define_name_rules verilog -allowed {A-Z a-z 0-9 _} \
    -first_restricted {0-9 _} -replacement_char "_"
change_names -rules verilog -hierarchy
set_fix_multiple_port_nets -all -buffer_constants
set verilogout_no_tri true

write_file -format verilog -hierarchy \
    -output synthesis/results/MIPS_SINGLE_CYC_netlist.v
write_file -format ddc -hierarchy \
    -output synthesis/results/MIPS_SINGLE_CYC_netlist.ddc
write_sdc -nosplit synthesis/results/MIPS_SINGLE_CYC.sdc
write_sdf synthesis/results/MIPS_SINGLE_CYC.sdf

# ------------------------- Essential Reports --------------------
puts "================ Essential Reports ==========="

check_design > synthesis/reports/check_design_post.rpt
check_timing > synthesis/reports/check_timing.rpt
report_qor > synthesis/reports/qor.rpt

report_area -hierarchy -nosplit > synthesis/reports/area.rpt
report_reference -hierarchy -nosplit > synthesis/reports/area_cells_by_reference.rpt

report_timing -delay_type max -max_paths 10 -nworst 1 \
    -input_pins -nets -transition_time -capacitance \
    -significant_digits 3 > synthesis/reports/setup.rpt
report_timing -delay_type min -max_paths 10 -nworst 1 \
    -input_pins -nets -transition_time -capacitance \
    -significant_digits 3 > synthesis/reports/hold.rpt

report_constraint -all_violators -verbose \
    > synthesis/reports/constraints_violators.rpt

# Vectorless estimate; annotate SAIF for activity-based power.
report_power -nosplit > synthesis/reports/power.rpt

puts "============== QUICK SUMMARY =============="
report_qor
report_area -nosplit
report_power -nosplit
puts "============================================"
puts "Synthesis script completed."
