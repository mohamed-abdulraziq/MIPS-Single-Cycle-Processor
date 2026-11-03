# Functional verification

The active testbench is tb_MIPS_extensive. From the repository root in QuestaSim / ModelSim:

~~~tcl
do verification/run.do
~~~

The supplied transcript reports 41 instructions, 65 observed cycles, 36 checks, one divide-by-zero event, zero errors, and ALL TESTS PASSED. The simulation was not rerun during repository packaging.

See [docs/VERIFICATION_RESULTS.md](../docs/VERIFICATION_RESULTS.md) and the root README for the waveform and transcript images.
