# Architecture assets

## RTL architecture overview

![MIPS Single-Cycle Processor RTL architecture](../images/architecture_overview.svg)

The vector figure above is the direct-view architecture illustration embedded in the root README as well. It shows the PC, instruction fetch, decode/control, register-file read, operand selection, ALSU, data memory, write-back, and PC target selection.

## Editable source

The original editable diagrams.net source is retained as [Phase1_MIPS_Single_Cycle.drawio](Phase1_MIPS_Single_Cycle.drawio). GitHub does not render Draw.io XML as a picture, so the SVG is the file intended for direct viewing.

The SVG is a clean high-level view. Exact ports, signal names, and RTL behavior are defined by the SystemVerilog source files.
