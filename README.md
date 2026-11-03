# MIPS Single-Cycle Processor

A 32-bit **MIPS-like single-cycle processor** implemented in SystemVerilog. The design integrates a custom 13-operation arithmetic/logic unit (ALSU), a 32 × 32-bit register file, byte-organized instruction and data memories, branch/jump control flow, and a self-checking QuestaSim verification environment. The ASIC synthesis flow targets the TSMC 130nm standard-cell library using Design Compiler.

> **ISA scope:** This project implements the instruction subset documented below. It is not a complete implementation of the standard MIPS ISA.

## Project overview

| Block | Implementation |
|---|---|
| Datapath | 32-bit single-cycle datapath |
| Control | Main opcode decoder and R-type function decoder |
| ALSU | 13 arithmetic, logic, multiply/divide, and comparison operations |
| Register file | 32 × 32-bit; two asynchronous read ports and one synchronous write port |
| Instruction memory | Byte-wide storage with a 32-bit instruction fetch interface |
| Data memory | Byte-wide storage with a 32-bit read/write interface |
| Control flow | PC+4, BEQ branch, and J jump |
| Exception behavior | Divide-by-zero detection suppresses register write-back |
| Verification | 41-instruction program, 36 self-checking checks |
| ASIC flow | Design Compiler synthesis using TSMC 130 nm standard cells |

## RTL architecture

![MIPS single-cycle processor RTL architecture](docs/images/architecture_overview.svg)

The diagram shows the processor's major blocks and datapath relationships. The editable diagrams.net source is retained in [docs/architecture/](docs/architecture/). The rendered image above is the direct-view architecture figure; GitHub does not render the Draw.io source as an image.

**RTL/source-of-truth note:** the architecture artwork is a high-level overview. Exact ports, signal names, and behavior are defined by the SystemVerilog source. In particular, the implemented data memory has an asynchronous read path and a synchronous write path controlled by MemWrite; no separate MemRead control output is implemented.

## Synthesized Design Vision schematic

![Design Vision schematic of the synthesized MIPS processor](docs/images/design_vision_schematic.webp)

This is the supplied Design Vision schematic-window capture for MIPI_Single_cyc_top_IMEM_DEPTH256_DMEM_DEPTH64. It is a zoomed-out schematic view, not a placement/routing layout or a physical-design sign-off image.

## Datapath operation

1. **Program counter:** PC_cntrl stores the 32-bit PC with an active-low asynchronous reset. PC_plus4 calculates PC+4, branch, and jump addresses.
2. **Instruction fetch:** instruction_mem stores 8-bit entries and assembles four consecutive bytes into a 32-bit instruction.
3. **Decode and register read:** control_unit decodes the opcode and R-type function code. Reg_file supplies two asynchronous operands and accepts one clocked write.
4. **Operand selection:** sign_ext extends the 16-bit immediate. MUX selects the second ALSU operand.
5. **Execute:** ALSU performs the selected arithmetic, logic, multiply/divide, or comparison operation. Its Zero output participates in BEQ control.
6. **Memory access:** Data_mem provides byte-wide storage with a 32-bit read/write interface.
7. **Write-back / next PC:** the datapath selects the destination register and result source, then selects PC+4, the branch target, or the jump target.

### Divide-by-zero behavior

When DIV is selected and the divisor is zero, ALSU asserts Division_Error and returns a zero result. The top level qualifies register write-back:

~~~systemverilog
assign RegWrite_final = RegWrite & ~Division_Error;
~~~

This is a combinational indication for the current instruction, not a sticky status register.

## Supported instruction subset

### R-type functions

| Operation | Funct[5:0] | ALSU control |
|---|---:|---:|
| ADD | 100000 | 0000 |
| SUB | 100010 | 0001 |
| MUL | 011000 | 0010 |
| DIV | 011010 | 0011 |
| AND | 100100 | 0100 |
| OR | 100101 | 0101 |
| NAND | 100110 | 0110 |
| NOR | 100111 | 0111 |
| XOR | 100001 | 1000 |
| XNOR | 100011 | 1001 |
| EQ | 101000 | 1010 |
| GT | 101010 | 1011 |
| LT | 101011 | 1100 |

### Other instructions

| Instruction | Opcode | Behavior |
|---|---:|---|
| BEQ | 000100 | Branch if the operands compare equal |
| ADDI | 001000 | Add a sign-extended immediate |
| J | 000010 | Jump to the assembled target address |
| LW | 100011 | Load a 32-bit word from data memory |
| SW | 101011 | Store a 32-bit word to data memory |

Unsupported R-type function codes do not enable register write-back. Writes to register zero are also suppressed.

## RTL source files

| File | Module | Responsibility |
|---|---|---|
| MIPI_Single_cyc_top.sv | MIPI_Single_cyc_top | Top-level integration and datapath connectivity |
| PC_cntrl.sv | PC_cntrl | Program-counter register |
| PC_plus4.sv | PC_plus4 | Sequential, branch, and jump address calculations |
| instruction_mem.sv | instruction_mem | Byte-wide instruction storage and word fetch |
| control_unit.sv | control_unit | Main decode, supported-function check, ALSU control |
| Reg_file.sv | Reg_file | 32 × 32-bit register file |
| sign_extend.sv | sign_ext | 16-to-32-bit immediate extension |
| MUX.sv | MUX | Parameterized datapath multiplexers |
| ALSU.sv | ALSU | 13 arithmetic/logic/comparison operations |
| Data_mem.sv | Data_mem | Byte-wide data memory with word access |

## Functional verification

The active testbench is tb_MIPS_extensive in [verification/tb_MIPS_top.sv](verification/tb_MIPS_top.sv). It loads the program while reset is asserted, releases reset, observes execution, and checks register-file/data-memory state and runtime control behavior.

### Recorded QuestaSim result

![QuestaSim transcript showing the supplied test run passing](docs/images/simulation_transcript.webp)

| Metric | Supplied transcript |
|---|---:|
| Instructions loaded | 41 |
| Observed cycles | 65 |
| Checks performed | 36 |
| Divide-by-zero events | 1 |
| Errors | 0 |
| Final status | **ALL TESTS PASSED** |

These values are transcribed from the supplied transcript screenshot. The simulation was not rerun during repository packaging.

### Waveform evidence

![QuestaSim waveform of the MIPS processor run](docs/images/questa_waveform.webp)

The waveform captures the fetch/program-flow signals, control outputs, register-file ports, ALSU operands/results, divide-by-zero indication, and data-memory interface. The transcript and self-checking testbench provide the pass/fail evidence.

### Test scenarios

- All 13 supported R-type operations, including signed arithmetic and comparisons.
- Positive and negative immediate values.
- Divide-by-zero detection and suppression of destination write-back.
- Register-zero write protection.
- Unsupported R-type function suppression.
- ADDI, LW, and SW operations.
- Taken and not-taken BEQ paths.
- Jump target and skipped-instruction behavior.
- Final PC check at the program self-loop.

See [docs/VERIFICATION_RESULTS.md](docs/VERIFICATION_RESULTS.md) for the testbench map and detailed evidence notes.

### Run with QuestaSim / ModelSim

From the repository root:

~~~tcl
do verification/run.do
~~~

For an interactive waveform session:

~~~tcl
vlib work
vlog -sv rtl/ALSU.sv rtl/MUX.sv rtl/sign_extend.sv \
     rtl/PC_cntrl.sv rtl/PC_plus4.sv rtl/Reg_file.sv \
     rtl/Data_mem.sv rtl/instruction_mem.sv \
     rtl/control_unit.sv rtl/MIPI_Single_cyc_top.sv \
     verification/tb_MIPS_top.sv
vsim work.tb_MIPS_extensive
do verification/wave.do
run -all
~~~

## ASIC synthesis - Design Compiler

The latest supplied synthesis evidence corresponds to the following setup:

| Setting | Recorded configuration |
|---|---|
| Top module | MIPI_Single_cyc_top |
| Elaborated memory depths | IMEM = 256 bytes; DMEM = 64 bytes |
| Clock period constraint | 166.7 ns (approximately 6.0 MHz) |
| Compile command | compile -map_effort medium |
| Target mapping library | TSMC CL013G RVT SS, 1.08 V, 125 °C |
| Linked libraries | SS, TT, and FF; FF associated as minimum library |

### Synthesis results

| Metric | Result |
|---|---:|
| Critical path length | 133.02 ns |
| Worst setup slack | +0.040 ns |
| Setup violating paths | 0 |
| Total negative slack | 0.00 ns |
| Minimum slack among the 10 reported hold paths | +0.294 ns |
| Mapped cell area | 358,855.853932 library area units |
| Mapped standard cells | 25,761 cells in area.rpt |
| Memory macros / black boxes | 0 |
| Vectorless total power estimate | 0.8376 mW |

The critical setup path starts at u_pc/PC_out_reg_2_ and ends at ALUResult_out[31]. The supplied timing report shows the path passing through instruction-memory read logic, register-file read logic, and the divider implementation inside ALSU. The +0.040 ns slack is positive but extremely small; the result meets only the recorded 166.7 ns constraint with little margin.

### Hierarchical area distribution

| Block | Cell area (library units) | Share of total |
|---|---:|---:|
| Instruction memory | 186,734.06 | 52.0% |
| ALSU | 65,854.02 | 18.4% |
| Data memory | 51,764.21 | 14.4% |
| Register file | 49,932.09 | 13.9% |
| PC calculation | 1,416.75 | 0.4% |
| PC register | 1,086.09 | 0.3% |
| Control unit | 271.82 | 0.1% |

The instruction and data memories together account for approximately 66.4% of mapped cell area. The reports show zero memory macros/black boxes, so these RTL byte arrays were mapped into standard-cell logic rather than SRAM macro instances. Within the ALSU, the divider contributes 41,989.36 library area units (11.7% of total design area), while the multiplier contributes 17,323.38 (4.8%).

### Power estimate

| Component | Result |
|---|---:|
| Cell internal power | 572.3166 µW |
| Net switching power | 20.0932 µW |
| Total dynamic power | 592.4099 µW |
| Cell leakage power | 245.2198 µW |
| **Total reported power** | **0.8376 mW** |

This is a low-effort vectorless synthesis estimate. The report warns that primary inputs and sequential outputs are unannotated; no representative SAIF activity annotation is included. It is not measured silicon power or workload-specific power.

### Raw synthesis reports

The raw uploaded reports are preserved under [synthesis/reports/](synthesis/reports/):

- [Area report](synthesis/reports/area.rpt)
- [Standard-cell reference distribution](synthesis/reports/area_cells_by_reference.rpt)
- [QoR report](synthesis/reports/qor.rpt)
- [Setup timing paths](synthesis/reports/setup_critical_path_excerpt.rpt)
- [Hold timing paths](synthesis/reports/hold.rpt)
- [Power estimate](synthesis/reports/power.rpt)
- [Pre-map design check](synthesis/reports/check_design_pre.rpt)
- [Post-map design check](synthesis/reports/check_design_post.rpt)
- [Full Design Compiler log](synthesis/reports/syn_MIPS.log)

The analysis and interpretation are documented in [docs/SYNTHESIS_RESULTS.md](docs/SYNTHESIS_RESULTS.md).

### Run synthesis

The proprietary technology libraries are not included in this repository. The timing constraints are the supplied initial interface assumptions, not constraints derived from a formal external interface specification.

## Scope and limitations

- This is a MIPS-like supported subset, not the complete MIPS ISA.
- Instruction and data memories are RTL byte arrays; the recorded synthesis maps them to standard cells, not SRAM macros.
- MUL and DIV are combinational operations in the shared ALSU.
- The divider is a significant area contributor and lies on the worst reported setup path.
- Timing and power values are pre-layout synthesis estimates; no place-and-route, clock-tree synthesis, extracted-parasitic STA, DRC/LVS, GDSII, or silicon measurement is claimed.

## Repository structure

~~~text
.
├── rtl/                         # Synthesizable SystemVerilog
├── verification/                 # Self-checking TB and Questa scripts
├── synthesis/
│   ├── syn_script_MIPS.tcl       # Design Compiler flow
│   ├── cons_MIPS.tcl             # Timing constraints
│   └── reports/                  # Original raw reports and log
└── docs/
    ├── images/                   # Architecture, schematic, transcript, waveform
    ├── architecture/             # Editable Draw.io source and image notes
    ├── SYNTHESIS_RESULTS.md      # Detailed synthesis analysis
    ├── VERIFICATION_RESULTS.md   # Testbench and simulation evidence
    └── RTL_REVIEW_NOTES.md       # RTL review observations
~~~

## Design ownership and AI assistance

The processor architecture, microarchitecture, RTL implementation, and functional design decisions were developed by the project author. AI assistance was limited to testbench writing/refinement, formatting, and documentation organization; it did not design or write the processor RTL.
