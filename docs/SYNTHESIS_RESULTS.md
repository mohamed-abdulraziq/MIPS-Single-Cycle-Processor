# ASIC Synthesis Results

## Evidence and configuration

This analysis is based on the user-supplied Synopsys Design Compiler K-2015.06 log and reports. The reports identify MIPI_Single_cyc_top_IMEM_DEPTH256_DMEM_DEPTH64 and a November 4, 2026 run.

| Parameter | Recorded value |
|---|---|
| Top module | MIPI_Single_cyc_top |
| IMEM depth | 256 bytes |
| DMEM depth | 64 bytes |
| Clock period | 166.7 ns (~6.0 MHz) |
| Compile | compile -map_effort medium |
| Target library | TSMC CL013G RVT SS, 1.08 V, 125 °C |
| Linked libraries | SS, TT and FF; FF associated as minimum library |

This is one synthesis configuration. SS is the target mapping library; FF is associated for minimum-delay analysis. It is not three independent corner runs.

## Timing

| Metric | Result |
|---|---:|
| Clock constraint | 166.70 ns |
| Critical path length | 133.02 ns |
| Worst setup slack | +0.040 ns |
| Total negative slack | 0.00 ns |
| Setup violating paths | 0 |
| Hold violations in QoR summary | 0 |
| Lowest slack among 10 displayed hold paths | +0.294 ns |

The worst setup path starts at u_pc/PC_out_reg_2_ and ends at ALUResult_out[31]. Its reported data arrival is 133.020 ns, required time 133.060 ns, and slack +0.040 ns. The detailed report shows instruction-memory logic, register-file read logic, and the divider u_alu/div_29 on the path.

**Interpretation:** the slack is positive but extremely small. The design meets the supplied 166.7 ns constraint with little margin.

## Area

| Hierarchical block | Cell area (library units) | Share |
|---|---:|---:|
| Instruction memory (u_imem) | 186,734.06 | 52.0% |
| ALSU (u_alu) | 65,854.02 | 18.4% |
| Data memory (u_dmem) | 51,764.21 | 14.4% |
| Register file (u_rf) | 49,932.09 | 13.9% |
| PC calculation (u_pc_calc) | 1,416.75 | 0.4% |
| PC register (u_pc) | 1,086.09 | 0.3% |
| Control unit (u_ctrl) | 271.82 | 0.1% |
| **Total** | **358,855.85** | **100%** |

The instruction and data memories together account for approximately 66.4% of mapped area. The reports show zero memory macros / black boxes; the RTL byte arrays were mapped into standard-cell logic, not foundry SRAM macros.

Within the ALSU, the divider contributes 41,989.36 library area units (11.7% of total design area), while the multiplier contributes 17,323.38 (4.8%). Library area units must not be interpreted as µm² without the library's area definition.

## Power estimate

| Metric | Result |
|---|---:|
| Cell internal power | 572.3166 µW |
| Net switching power | 20.0932 µW |
| Total dynamic power | 592.4099 µW |
| Cell leakage power | 245.2198 µW |
| **Total reported power** | **0.8376 mW** |

The report used low analysis effort and a vectorless activity estimate. It warns that primary inputs and sequential outputs are unannotated. No representative SAIF activity annotation is included. This is a synthesis estimate, not measured silicon power or workload-specific power.


## Design Vision schematic

![Design Vision schematic](images/design_vision_schematic.webp)

The supplied capture is a zoomed-out synthesized schematic-window screenshot. It is not a physical layout, place-and-route result, or sign-off image.


The proprietary technology libraries are not redistributed. The constraints are the supplied initial interface assumptions, not constraints derived from a formal external interface specification.

## Scope and limitations

This evidence demonstrates RTL elaboration, technology mapping, and Design Compiler report generation for the stated setup. It does not demonstrate place-and-route, clock-tree synthesis, extracted-parasitic STA, DRC/LVS closure, GDSII generation, fabrication, or silicon measurement.
