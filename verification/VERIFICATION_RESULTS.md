# Verification Results

## Testbench and execution

The active self-checking testbench module is `tb_MIPS_extensive`, located in [tb_MIPS_top.sv](tb_MIPS_top.sv). It loads a 41-instruction program into instruction memory, releases reset, and observes the processor over 65 cycles.

The testbench checks register-file and data-memory state against expected values and monitors divide-by-zero behavior and register-write suppression. Program storage capacity is 42 words; the generated program contains 41 instructions, with the final instruction used as a self-loop.

## Supplied simulation transcript

![QuestaSim transcript](../docs/images/simulation_transcript.webp)

| Metric | Recorded result |
|---|---:|
| Instructions loaded | 41 |
| Cycles observed | 65 |
| Checks performed | 36 |
| Divide-by-zero events | 1 |
| Errors | 0 |
| Final status | **ALL TESTS PASSED** |

These values are transcribed from the supplied transcript screenshot. The test was not rerun during repository packaging.

## Waveform evidence

![QuestaSim waveform](../docs/images/questa_waveform.webp)

The waveform screenshot shows the clock/reset, instruction fetch/program flow, control outputs, register-file read/write ports, ALSU operands and result, divide-by-zero indication, and data-memory signals.

## Covered scenarios

- The 13 supported R-type operations: ADD, SUB, MUL, DIV, AND, OR, NAND, NOR, XOR, XNOR, EQ, GT, and LT.
- Signed arithmetic and comparison behavior.
- Positive and negative ADDI immediate values.
- Divide-by-zero: Division_Error asserted, zero result, and register write-back suppressed.
- Register-zero write protection.
- Unsupported R-type function code suppression.
- SW and LW data-memory behavior.
- Taken and not-taken BEQ paths.
- Jump target selection and skipped instruction behavior.
- Final PC self-loop behavior.

## Reproducing the simulation

The repository keeps the self-checking testbench source in this directory without simulator-specific run scripts. Compile the RTL source files under `rtl/` together with `tb_MIPS_top.sv` in QuestaSim / ModelSim, then run the `tb_MIPS_extensive` testbench. The transcript and waveform above are supplied evidence from the recorded run; they were not regenerated during repository packaging.
