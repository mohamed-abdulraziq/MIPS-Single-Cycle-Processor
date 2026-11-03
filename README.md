# MIPS Single-Cycle Processor

A 32-bit MIPS-like single-cycle processor implemented in SystemVerilog, with a custom 13-operation ALU/ALSU, register and memory interfaces, branch/jump control flow, self-checking verification, and a Synopsys Design Compiler synthesis flow targeting a TSMC 130 nm standard-cell library.

## Architecture

The processor is organized around a 32-bit datapath and a single-cycle control path.

- 32-bit program counter with active-low reset.
- Byte-wide instruction memory with a 32-bit instruction output.
- 32 × 32-bit register file with two read ports and one write port.
- Register zero (R0) is protected from writes.
- 16-to-32-bit sign extension.
- ALU/ALSU supporting 13 operations.
- Byte-wide data memory with 32-bit read/write interface.
- BEQ branch and J jump control flow.
- Division-by-zero detection suppresses register write-back.

## Supported Operations

### R-Type ALU functions

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

This is the implemented/tested instruction subset, not a claim of full MIPS ISA compatibility.

## Verification

The project includes an extensive self-checking SystemVerilog testbench.

The test program exercises:
- All 13 supported R-type ALU functions.
- ADDI with positive and negative immediates.
- Load/store data path.
- Taken and not-taken BEQ.
- Jump target and skipped instruction behavior.
- R0 write protection.
- Unsupported R-type function write suppression.
- Division-by-zero detection and destination-register write suppression.
- Signed comparisons and final PC behavior.

**Previously reported simulation result:** 41 instructions loaded, 65 observed cycles, 36 checks, one division-by-zero event, zero errors, and `ALL TESTS PASSED`. This is a result from a prior simulation session and has not been rerun as part of this repository upload.

## Synthesis

The provided Design Compiler flow is configured for:

- Top module: `MIPI_Single_cyc_top`
- Clock target: 20 ns (50 MHz)
- Instruction memory depth: 256 bytes
- Data memory depth: 64 bytes
- TSMC 130 nm standard-cell libraries:
  - SS: `scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db`
  - TT: `scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db`
  - FF: `scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db`

The synthesis script uses the SS library as the target mapping library; TT and FF are linked, with FF associated as the minimum library. This is not three independent synthesis runs.

Power reporting is vectorless unless representative switching activity is annotated. Timing constraints are initial assumptions and should be replaced with the actual integration interface requirements. Synthesis results are not place-and-route or silicon measurements.

## Repository Structure

```text
rtl/                  SystemVerilog design source
verification/         Testbench and waveform setup
synthesis/             Design Compiler scripts and constraints
docs/architecture/    Editable Draw.io architecture
docs/images/           Architecture overview image
```

## Tools

- SystemVerilog
- QuestaSim / ModelSim
- Synopsys Design Compiler
- TSMC 130 nm standard-cell library

## Notes

The instruction and data memories are modeled as byte arrays in RTL; they are not foundry SRAM macro instances. The combinational division operator and the single-cycle critical path can have significant area and timing impact.

## License

No license has been assigned yet.
