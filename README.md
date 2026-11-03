# MIPS Single-Cycle Processor

A 32-bit MIPS-like single-cycle processor implemented in SystemVerilog. The project includes a custom 13-operation ALU/ALSU, register and byte-organized memory interfaces, branch/jump control flow, a self-checking verification environment, and a Synopsys Design Compiler synthesis flow targeting a TSMC 130 nm standard-cell library.

> **ISA scope:** This is a MIPS-like processor implementing the instruction subset documented below; it is not a complete implementation of the standard MIPS ISA.

## Project ownership and development

The RTL architecture, microarchitecture decisions, functional design, verification plan, test scenarios, expected results, and testbench behavior were developed by the project author.

AI assistance was used after the design and verification work to help with code writing/refinement, formatting, and documentation presentation. It did not originate the architecture, functional design, verification strategy, or test scenarios.

Some source sections are intentionally retained as comments. These include optional waveform-observation declarations and an alternative/commented implementation kept for reference. The commented legacy `tb` block in the testbench is not the active regression; the active self-checking testbench is `tb_MIPS_extensive`. The active RTL modules are the non-commented implementations.

## Architecture

The processor is organized around a 32-bit datapath and a single-cycle control path.

- 32-bit program counter with active-low reset.
- Byte-wide instruction memory with a 32-bit instruction output.
- 32 × 32-bit register file with two read ports and one write port.
- Register zero (R0) is protected from writes.
- 16-to-32-bit sign extension.
- ALU/ALSU supporting 13 operations.
- Byte-wide data memory with a 32-bit read/write interface.
- BEQ branch and J jump control flow.
- Division-by-zero detection suppresses register write-back.

### Datapath building blocks

| Module | Responsibility |
|---|---|
| `MIPI_Single_cyc_top` | Top-level processor integration |
| `PC_cntrl` | PC register and reset behavior |
| `PC_plus4` | PC+4, branch-target, and jump-target calculations |
| `MUX` | Parameterized datapath/PC selection |
| `sign_ext` | 16-bit immediate sign extension |
| `Reg_file` | 32 × 32-bit register file |
| `control_unit` | Main instruction decoder and ALU decoder |
| `ALSU` | Arithmetic, logic, multiply/divide, and comparison operations |
| `instruction_mem` | Byte-wide instruction storage and instruction fetch |
| `Data_mem` | Byte-wide data storage and 32-bit data access |

## Supported operations

### R-type ALU functions

| Operation | Function |
|---|---|
| ADD | `100000` |
| SUB | `100010` |
| MUL | `011000` |
| DIV | `011010` |
| AND | `100100` |
| OR | `100101` |
| NAND | `100110` |
| NOR | `100111` |
| XOR | `100001` |
| XNOR | `100011` |
| EQ | `101000` |
| GT | `101010` |
| LT | `101011` |

### Other instruction opcodes

| Instruction | Opcode |
|---|---|
| BEQ | `000100` |
| ADDI | `001000` |
| J | `000010` |
| LW | `100011` |
| SW | `101011` |

## Functional safeguards

- **R0 protection:** writes to register zero are blocked.
- **Unsupported R-type functions:** register write-back is enabled only for the 13 supported function codes.
- **Division by zero:** the ALSU raises `Division_Error`, produces a zero ALU result, and the top-level logic suppresses register write-back for that instruction.

## Verification

The active self-checking testbench is `tb_MIPS_extensive` in `tb_MIPS_top.sv`. The earlier `tb` module at the beginning of that file is fully commented out and is not the regression top.

The active testbench includes:

- A 41-instruction program loaded into instruction memory while the processor is held in reset.
- All 13 supported R-type ALU functions.
- ADDI with positive and negative immediates, including signed-boundary values.
- Load/store behavior and a data-memory readback check.
- Taken BEQ and verification that the following instruction is skipped.
- Jump behavior and verification that the skipped instruction does not write its destination.
- R0 write protection.
- Unsupported R-type function write suppression.
- Division-by-zero detection, zero-result behavior, and write-enable suppression.
- Signed comparison cases.
- Runtime monitoring of `Division_Error` and `RegWrite_final`.
- Final PC/self-loop verification and a global simulation timeout.

**Previously reported simulation result (historical):**

| Metric | Reported result |
|---|---:|
| Instructions loaded | 41 |
| Observed cycles | 65 |
| Checks | 36 |
| Division-by-zero events | 1 |
| Errors | 0 |
| Status | `ALL TESTS PASSED` |

This result was reported from a previous simulation session. It is not represented as a fresh regression run performed during this repository update.

## ASIC synthesis

The design is intended to be synthesized using Synopsys Design Compiler and a TSMC 130 nm standard-cell library.

### Technology libraries

The previous synthesis setup references:

- SS: `scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db`
- TT: `scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db`
- FF: `scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db`

The SS library is the target mapping library; TT and FF are linked, with FF associated as the minimum library. This is not three independent synthesis runs. Proprietary technology libraries are not included.

### Previous synthesis run — preliminary baseline

The available Design Compiler log and reports correspond to a **20 ns (50 MHz)** clock constraint. This run did not meet timing.

| Metric | Previous reported result |
|---|---:|
| Clock constraint | 20 ns (50 MHz) |
| Critical path length | 21.21 ns |
| Critical path slack | -5.51 ns |
| Setup-violating paths | 2,078 |
| Total cell area | 337,344.60 library area units |
| Cell count | 32,252 |
| Dynamic power estimate | 4.6906 mW |
| Cell leakage power | 239.5997 µW |

The intended operating target discussed for the project is **6 MHz**, corresponding to approximately **166.667 ns**. A corrected synthesis run with that constraint is pending. The 20 ns run is retained as a preliminary baseline only; its area and power must not be presented as final results for the corrected run because synthesis optimization and mapping may change.

Power is a vectorless estimate unless representative switching activity is annotated. Library area units are not automatically equivalent to µm². These are synthesis results, not place-and-route or silicon measurements.

## Repository structure

```text
.
├── rtl/                    # SystemVerilog design modules
├── verification/           # Self-checking testbench and simulator setup
├── synthesis/              # Design Compiler scripts, constraints, and reports
├── docs/
│   ├── architecture/       # Architecture documentation and editable source
│   └── images/             # Exported architecture figures
└── README.md
```

## Tools

- SystemVerilog
- QuestaSim / ModelSim
- Synopsys Design Compiler
- TSMC 130 nm standard-cell library

## Scope and limitations

- MIPS-like implemented instruction subset; not full MIPS ISA compatibility.
- Single-cycle datapath; the combinational division operator and single-cycle critical path can have significant area and timing impact.
- Instruction and data memories are modeled as RTL byte arrays; foundry SRAM macro inference is not claimed.
- No Place and Route, Clock Tree Synthesis, physical verification, DRC/LVS, GDSII generation, or silicon measurement is claimed.

## License

No license has been assigned yet.
