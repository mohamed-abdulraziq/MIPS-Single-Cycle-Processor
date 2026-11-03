
# Architecture Overview

![MIPS Single-Cycle Processor architecture](../images/architecture_overview.svg)

The SVG is the direct-view architecture figure used by the root README. It is arranged into two sections:

1. **Program counter and control flow:** PC register, PC+4 / branch / jump target generation, branch selection, jump selection, and next-PC feedback.
2. **Instruction decode, execution, and write-back:** byte-organized instruction memory, opcode/function decode, two-read/one-write register file, immediate sign extension, ALUSrc selection, 13-operation ALSU, byte-organized data memory, and MemtoReg selection.

The figure is a functional block-level view. Exact ports, signal widths, logic, and control behavior are defined by the SystemVerilog RTL. The SVG is maintained for crisp scaling in GitHub.
