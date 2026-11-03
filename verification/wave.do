# QuestaSim waveform setup for tb_MIPS_extensive
onerror {resume}
quietly WaveActivateNextPane {} 0
delete wave *
add wave -divider {CLOCK / TESTBENCH}
add wave /tb_MIPS_extensive/CLK
add wave /tb_MIPS_extensive/rst_n
add wave -radix unsigned /tb_MIPS_extensive/cycle_count
add wave -radix unsigned /tb_MIPS_extensive/checks
add wave -radix unsigned /tb_MIPS_extensive/errors
add wave /tb_MIPS_extensive/dut/PC
add wave -radix hex /tb_MIPS_extensive/dut/Instr
add wave -radix hex /tb_MIPS_extensive/dut/PCPlus4
add wave -radix hex /tb_MIPS_extensive/dut/PCNext
add wave -divider {CONTROL}
add wave /tb_MIPS_extensive/dut/RegWrite
add wave /tb_MIPS_extensive/dut/RegWrite_final
add wave /tb_MIPS_extensive/dut/RegDst
add wave /tb_MIPS_extensive/dut/ALUSrc
add wave /tb_MIPS_extensive/dut/MemWrite
add wave /tb_MIPS_extensive/dut/MemtoReg
add wave -radix binary /tb_MIPS_extensive/dut/ALUControl
add wave -divider {REGISTER FILE}
add wave -radix unsigned /tb_MIPS_extensive/dut/WriteReg
add wave -radix hex /tb_MIPS_extensive/dut/RD1
add wave -radix hex /tb_MIPS_extensive/dut/RD2
add wave -radix hex /tb_MIPS_extensive/dut/WriteData
add wave -radix hex /tb_MIPS_extensive/dut/Result
add wave -divider {ALSU}
add wave -radix hex /tb_MIPS_extensive/dut/SrcA
add wave -radix hex /tb_MIPS_extensive/dut/SrcB
add wave -radix hex /tb_MIPS_extensive/dut/ALUResult
add wave /tb_MIPS_extensive/dut/Zero
add wave /tb_MIPS_extensive/dut/Division_Error
add wave -divider {DATA MEMORY}
add wave -radix hex /tb_MIPS_extensive/dut/ReadData
add wave /tb_MIPS_extensive/dut/MemWrite
add wave -radix hex -expand /tb_MIPS_extensive/dut/u_dmem/data_mem
add wave -divider {TOP LEVEL OUTPUTS}
add wave -radix hex /tb_MIPS_extensive/PC_out
add wave -radix hex /tb_MIPS_extensive/ALUResult_out
configure wave -namecolwidth 260
configure wave -valuecolwidth 140
configure wave -timelineunits ns
update
