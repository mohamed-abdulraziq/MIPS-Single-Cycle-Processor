#####################################################################
# cons_MIPS.tcl - timing constraints for MIPS Single-Cycle Processor
# Sourced by syn_script_MIPS.tcl
#####################################################################

set CLK_PORT      CLK
set RST_PORT      rst_n
set CLK_NAME      CLK

set SETUP_UNCERT  0.30
set HOLD_UNCERT   0.10
set CLK_TRANS     0.10

set IN_DELAY_PCT  0.20
set OUT_DELAY_PCT 0.20
set OUT_LOAD      0.5

# Clock
create_clock -name $CLK_NAME -period $CLK_PERIOD \
    -waveform [list 0 [expr {$CLK_PERIOD / 2.0}]] \
    [get_ports $CLK_PORT]

set_clock_uncertainty -setup $SETUP_UNCERT [get_clocks $CLK_NAME]
set_clock_uncertainty -hold  $HOLD_UNCERT  [get_clocks $CLK_NAME]
set_clock_transition $CLK_TRANS [get_clocks $CLK_NAME]
set_dont_touch_network [get_clocks $CLK_NAME]

# Asynchronous active-low reset
set_dont_touch_network [get_ports $RST_PORT]
set_drive 0 [get_ports $RST_PORT]

# Data inputs: exclude clock and reset
set data_inputs [remove_from_collection [all_inputs] \
    [get_ports [list $CLK_PORT $RST_PORT]]]

set_input_delay [expr {$IN_DELAY_PCT * $CLK_PERIOD}] \
    -clock $CLK_NAME $data_inputs

# Reset is asynchronous; do not apply ordinary data input delay to it.
# Clock input is constrained by create_clock.

# Input drive model.
# BUFX2M must exist in the loaded TSMC library; if not, replace it with
# a valid buffer cell name from that library.
set_driving_cell -lib_cell BUFX2M $data_inputs

# Outputs
set_output_delay [expr {$OUT_DELAY_PCT * $CLK_PERIOD}] \
    -clock $CLK_NAME [all_outputs]
set_load $OUT_LOAD [all_outputs]

# No arbitrary max-area target is imposed; area is reported after mapping.
