# Simulation Evidence

The supplied ModelSim/Questa transcript screenshot reports the following result for the extensive MIPS testbench:

| Metric | Reported value |
|---|---:|
| Instructions loaded | 41 |
| Cycles observed | 65 |
| Checks performed | 36 |
| Division-by-zero events | 1 |
| Errors | 0 |
| Final status | **ALL TESTS PASSED** |

This is a transcription of the supplied simulation evidence. It is not a claim that the testbench was rerun during this repository update. The testbench source is verification/tb_MIPS_top.sv; the active top module is tb_MIPS_extensive.

The separate supplied waveform screenshot shows instruction fetch, PC progression, control signals, register-file ports, and datapath signals. A waveform screenshot is illustrative evidence; the self-checking testbench transcript is the source for the pass/fail summary.
