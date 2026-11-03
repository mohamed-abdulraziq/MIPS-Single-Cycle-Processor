# ASIC synthesis

Run from the repository root after updating LIB_DIR in syn_script_MIPS.tcl to the location of the licensed TSMC .db libraries:

~~~bash
dc_shell -f synthesis/syn_script_MIPS.tcl | tee synthesis/reports/syn_MIPS.log
~~~

The supplied run uses a 166.7 ns clock constraint, IMEM_DEPTH=256 bytes, DMEM_DEPTH=64 bytes, and compile -map_effort medium.

The reports folder contains the raw area, cell-reference, QoR, hold, power, pre-map/post-map design-check reports, and the full synthesis log. A concise worst-setup-path excerpt is also provided; the complete setup report is generated again when the flow is rerun.

See [docs/SYNTHESIS_RESULTS.md](../docs/SYNTHESIS_RESULTS.md) for detailed interpretation and limitations. Proprietary .db libraries are not redistributed.
