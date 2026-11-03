# ===================================================================
#  wave.do - MIPS Single-Cycle Processor (Extensive Testbench)
#  Hierarchy: tb_MIPS_extensive / dut
# ===================================================================

onerror {resume}
quietly WaveActivateNextPane {} 0
delete wave *

# -------------------------------------------------------------------
# CLOCK / RESET / TESTBENCH STATUS
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {CLOCK / RESET / TESTBENCH}
add wave -noupdate -color Yellow -label CLK /tb_MIPS_extensive/CLK
add wave -noupdate -color Orange -label rst_n /tb_MIPS_extensive/rst_n
add wave -noupdate -radix unsigned -label cycle_count /tb_MIPS_extensive/cycle_count
add wave -noupdate -radix unsigned -label program_index /tb_MIPS_extensive/program_index
add wave -noupdate -radix unsigned -label errors /tb_MIPS_extensive/errors
add wave -noupdate -radix unsigned -label checks /tb_MIPS_extensive/checks
add wave -noupdate -radix unsigned -label div_zero_events /tb_MIPS_extensive/div_zero_events

# Instruction memory programming interface
add wave -noupdate -divider -height 25 {INSTRUCTION MEMORY LOAD}
add wave -noupdate -label imem_WE /tb_MIPS_extensive/imem_WE
add wave -noupdate -radix hex -label imem_WA /tb_MIPS_extensive/imem_WA
add wave -noupdate -radix hex -label imem_WD /tb_MIPS_extensive/imem_WD

# -------------------------------------------------------------------
# FETCH / PROGRAM FLOW
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {FETCH / PROGRAM FLOW}
add wave -noupdate -color Cyan -radix hex -label PC /tb_MIPS_extensive/dut/PC
add wave -noupdate -color Gold -label Instruction /tb_MIPS_extensive/dut/Instr
add wave -noupdate -label Instr_hex -radix hex /tb_MIPS_extensive/dut/Instr
add wave -noupdate -radix hex -label PCPlus4 /tb_MIPS_extensive/dut/PCPlus4
add wave -noupdate -radix hex -label PCBranch /tb_MIPS_extensive/dut/PCBranch
add wave -noupdate -radix hex -label PCJump /tb_MIPS_extensive/dut/PCJump
add wave -noupdate -radix hex -label PCBrMuxOut /tb_MIPS_extensive/dut/PCBrMuxOut
add wave -noupdate -radix hex -label PCNext /tb_MIPS_extensive/dut/PCNext
add wave -noupdate -label PCSrc /tb_MIPS_extensive/dut/PCSrc
add wave -noupdate -label Branch /tb_MIPS_extensive/dut/Branch
add wave -noupdate -label Jump /tb_MIPS_extensive/dut/Jump

# -------------------------------------------------------------------
# CONTROL UNIT
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {CONTROL UNIT}
add wave -noupdate -radix binary -label Op {/tb_MIPS_extensive/dut/Instr[31:26]}
add wave -noupdate -radix binary -label Funct {/tb_MIPS_extensive/dut/Instr[5:0]}
add wave -noupdate -color {Medium Orchid} -label RegWrite_raw /tb_MIPS_extensive/dut/RegWrite
add wave -noupdate -color {Medium Orchid} -label RegWrite_final /tb_MIPS_extensive/dut/RegWrite_final
add wave -noupdate -color {Medium Orchid} -label RegDst /tb_MIPS_extensive/dut/RegDst
add wave -noupdate -color {Medium Orchid} -label ALUSrc /tb_MIPS_extensive/dut/ALUSrc
add wave -noupdate -color {Medium Orchid} -label MemWrite /tb_MIPS_extensive/dut/MemWrite
add wave -noupdate -color {Medium Orchid} -label MemtoReg /tb_MIPS_extensive/dut/MemtoReg
add wave -noupdate -color {Medium Orchid} -label ALUControl -radix binary /tb_MIPS_extensive/dut/ALUControl

# -------------------------------------------------------------------
# REGISTER FILE DATAPATH
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {REGISTER FILE PORTS}
add wave -noupdate -radix unsigned -label A1_rs {/tb_MIPS_extensive/dut/Instr[25:21]}
add wave -noupdate -radix unsigned -label A2_rt {/tb_MIPS_extensive/dut/Instr[20:16]}
add wave -noupdate -radix unsigned -label A3_WriteReg /tb_MIPS_extensive/dut/WriteReg
add wave -noupdate -radix hex -label RD1 /tb_MIPS_extensive/dut/RD1
add wave -noupdate -radix hex -label RD2 /tb_MIPS_extensive/dut/RD2
add wave -noupdate -radix hex -label WriteData /tb_MIPS_extensive/dut/WriteData
add wave -noupdate -radix hex -label Result_Writeback /tb_MIPS_extensive/dut/Result
add wave -noupdate -label RegWrite_final /tb_MIPS_extensive/dut/RegWrite_final

# -------------------------------------------------------------------
# ALU / DIVISION ERROR
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {ALU / DIVISION ERROR}
add wave -noupdate -radix decimal -color {Spring Green} -label SrcA_signed /tb_MIPS_extensive/dut/SrcA
add wave -noupdate -radix decimal -color {Spring Green} -label SrcB_signed /tb_MIPS_extensive/dut/SrcB
add wave -noupdate -radix hex -color {Spring Green} -label SrcA_hex /tb_MIPS_extensive/dut/SrcA
add wave -noupdate -radix hex -color {Spring Green} -label SrcB_hex /tb_MIPS_extensive/dut/SrcB
add wave -noupdate -radix decimal -color {Spring Green} -label ALUResult_signed /tb_MIPS_extensive/dut/ALUResult
add wave -noupdate -radix hex -label ALUResult_hex /tb_MIPS_extensive/dut/ALUResult
add wave -noupdate -label Zero /tb_MIPS_extensive/dut/Zero
add wave -noupdate -radix decimal -label SignImm_signed /tb_MIPS_extensive/dut/SignImm
add wave -noupdate -radix hex -label SignImm_hex /tb_MIPS_extensive/dut/SignImm
add wave -noupdate -color Red -label Division_Error /tb_MIPS_extensive/dut/Division_Error

# -------------------------------------------------------------------
# DATA MEMORY
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {DATA MEMORY}
add wave -noupdate -radix hex -label DataMem_Address /tb_MIPS_extensive/dut/ALUResult
add wave -noupdate -radix hex -label DataMem_WriteData /tb_MIPS_extensive/dut/WriteData
add wave -noupdate -radix hex -label DataMem_ReadData /tb_MIPS_extensive/dut/ReadData
add wave -noupdate -label DataMem_WE /tb_MIPS_extensive/dut/MemWrite
add wave -noupdate -radix hex -expand -label DATA_MEM_BYTES /tb_MIPS_extensive/dut/u_dmem/data_mem

# -------------------------------------------------------------------
# REGISTER FILE CONTENTS
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {REGISTER FILE CONTENTS}
add wave -noupdate -radix hex -expand -label REG_FILE /tb_MIPS_extensive/dut/u_rf/REG_FILE

# -------------------------------------------------------------------
# TOP-LEVEL OBSERVATION PORTS
# -------------------------------------------------------------------
add wave -noupdate -divider -height 25 {TOP LEVEL OUTPUTS}
add wave -noupdate -radix hex -label PC_out /tb_MIPS_extensive/PC_out
add wave -noupdate -radix hex -label ALUResult_out /tb_MIPS_extensive/ALUResult_out

# -------------------------------------------------------------------
# WAVE WINDOW FORMATTING
# -------------------------------------------------------------------
configure wave -namecolwidth 260
configure wave -valuecolwidth 140
configure wave -signalnamewidth 1
configure wave -justifyvalue left
configure wave -timelineunits ns
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

update