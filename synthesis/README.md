
# ASIC Synthesis

The Design Compiler flow is launched from the repository root.

1. Set LIB_DIR in syn_script_MIPS.tcl to the local directory containing the licensed TSMC .db files.
2. Confirm that the configured library files exist and that BUFX2M is present in the selected library.
3. Run:

~~~bash
dc_shell -f synthesis/syn_script_MIPS.tcl
~~~

The supplied run used a 166.7 ns clock constraint, IMEM_DEPTH=256 bytes, DMEM_DEPTH=64 bytes, and compile -map_effort medium.

Design Compiler report files are written to the local synthesis/reports/ folder for engineering inspection. The folder is intentionally ignored by Git and is not part of the public repository. The public summary is in docs/SYNTHESIS_RESULTS.md.

The proprietary technology libraries are not redistributed. This is a synthesis flow; it does not include place-and-route, extracted-parasitic STA, DRC, or LVS.
