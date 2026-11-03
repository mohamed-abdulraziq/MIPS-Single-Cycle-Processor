# MIPS Single-Cycle Processor

A 32-bit MIPS-like single-cycle processor implemented in SystemVerilog. The project includes a custom 13-operation ALU/ALSU, register and byte-organized memory interfaces, branch/jump control flow, a self-checking verification environment, and a Synopsys Design Compiler flow targeting a TSMC 130 nm standard-cell library.

> **ISA scope:** This is a MIPS-like processor implementing the subset documented below; it is not a complete implementation of the standard MIPS ISA.

## Design ownership and AI assistance

The processor architecture, microarchitecture, RTL design and implementation, and functional design decisions were entirely developed and written by the project author. The verification plan, test scenarios, expected behavior, and verification intent were also defined by the author.

AI assistance was limited to helping with testbench writing/refinement and formatting, plus documentation organization and presentation. It did not design or write the processor RTL.

## Architecture

- 32-bit program counter with active-low reset.
- Byte-wide instruction memory with a 32-bit instruction output.
- 32 × 32-bit register file with two read ports and one write port.
- Register zero (R0) is protected from writes.
- 16-to-32-bit sign extension.
- ALU/ALSU supporting 13 operations.
- Byte-wide data memory with a 32-bit read/write interface.
- BEQ branch and J jump control flow.
- Division-by-zero detection suppresses register write-back.

The editable architecture source is docs/architecture/Phase1_MIPS_Single_Cycle.drawio. Open it with diagrams.net. RTL is the implementation source of truth.

### RTL modules

| Module | Responsibility |
|---|---|
| MIPI_Single_cyc_top | Top-level processor integration |
| PC_cntrl | Program-counter register and reset |
| PC_plus4 | PC+4 and branch/jump address calculations |
| MUX | Parameterized datapath selection |
| sign_ext | Immediate sign extension |
| Reg_file | 32 × 32-bit register file |
| control_unit | Instruction and ALU control decoding |
| ALSU | Arithmetic, logic, multiply/divide, and comparisons |
| instruction_mem | Byte-wide instruction storage/fetch |
| Data_mem | Byte-wide data storage/access |

## Implemented instruction subset

### R-type functions

| Operation | Function code |
|---|---|
| ADD | 100000 |
| SUB | 100010 |
| MUL | 011000 |
| DIV | 011010 |
| AND | 100100 |
| OR | 100101 |
| NAND | 100110 |
| NOR | 100111 |
| XOR | 100001 |
| XNOR | 100011 |
| EQ | 101000 |
| GT | 101010 |
| LT | 101011 |

### Other instructions

| Instruction | Opcode |
|---|---|
| BEQ | 000100 |
| ADDI | 001000 |
| J | 000010 |
| LW | 100011 |
| SW | 101011 |

## Verification

The active self-checking testbench is tb_MIPS_extensive in verification/tb_MIPS_top.sv.

The extensive testbench has storage capacity for 42 instruction words and emits/checks a 41-instruction program. It checks the supported R-type functions, immediate operations, load/store behavior, BEQ and jump control flow, R0 protection, unsupported R-type handling, signed comparisons, and division-by-zero behavior.

### Run with QuestaSim / ModelSim

From the repository root, run the following in the QuestaSim / ModelSim transcript:

```tcl
do verification/run_questa.do
```

Or compile and run manually:

```tcl
vlib work
vlog -sv rtl/ALSU.sv rtl/MUX.sv rtl/sign_extend.sv \
     rtl/PC_cntrl.sv rtl/PC_plus4.sv rtl/Reg_file.sv \
     rtl/Data_mem.sv rtl/instruction_mem.sv \
     rtl/control_unit.sv rtl/MIPI_Single_cyc_top.sv \
     verification/tb_MIPS_top.sv
vsim -c tb_MIPS_extensive -do "run -all; quit -f"
```

For an interactive waveform session:

```tcl
vsim work.tb_MIPS_extensive
do verification/wave_MIPS_extensive.do
run -all
```

**Previously reported simulation evidence:** 41 instructions loaded, 65 observed cycles, 36 checks, one division-by-zero event, zero errors, and ALL TESTS PASSED. This is historical evidence from the supplied simulation transcript, not a fresh run performed while packaging this repository. A concise record is in docs/simulation_results.md.

## ASIC synthesis — Synopsys Design Compiler

The synthesis flow is in synthesis/ and is configured for:

- Top module: MIPI_Single_cyc_top
- Clock period: 166.667 ns (6 MHz)
- Instruction memory depth: 256 bytes
- Data memory depth: 64 bytes
- Target mapping library: TSMC 130 nm SS
- Linked libraries: SS, TT, and FF; FF is associated as the minimum library

The RTL module defaults for memory depth differ from the synthesis elaboration parameters. The script explicitly overrides them to 256 and 64 bytes for this synthesis configuration.

Run from the repository root:

```bash
dc_shell -f synthesis/syn_script_MIPS.tcl | tee synthesis/syn_MIPS.log
```

### Essential synthesis reports

The script intentionally generates a concise set of reports:

| Report | Purpose |
|---|---|
| check_design_pre.rpt | Design checks before mapping |
| check_design_post.rpt | Design checks after mapping |
| check_timing.rpt | Timing setup/constraint sanity |
| qor.rpt | Overall synthesis QoR summary |
| area.rpt | Total and hierarchical cell area |
| area_cells_by_reference.rpt | Mapped cell-type distribution |
| setup.rpt | Worst setup paths |
| hold.rpt | Worst hold paths |
| constraints_violators.rpt | Reported constraint violations |
| power.rpt | Vectorless power estimate |


**Interpretation limits:** Power is vectorless unless representative SAIF activity is annotated. Library area units must not be assumed to be µm². Synthesis is not place-and-route; no CTS, routed parasitics, DRC/LVS, GDSII, or silicon measurement is claimed.

## Known design considerations

- Instruction and data memories are RTL byte arrays; no foundry SRAM macro mapping is claimed.
- The combinational division operator may have substantial area and timing cost.
- In a single-cycle architecture, the longest combinational instruction path limits the clock frequency.
- IMEM_DEPTH and DMEM_DEPTH are byte depths.

## Repository structure

```text
.
├── rtl/                    # Synthesizable SystemVerilog modules
├── verification/           # Testbench and simulator setup
├── synthesis/              # DC scripts and timing constraints
└── docs/
    └── architecture/       # Editable Draw.io architecture source
```
