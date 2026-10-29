# riscv-soc-interconnect-uvm
Constrained-random UVM verification of a memory-mapped RISC-V SoC interconnect with SRAM, frame buffer and MMIO peripherals
# Constrained-Random UVM Verification of a Memory-Mapped SoC Interconnect

## Overview

This project aims to develop and verify a memory-mapped SoC interconnect for a RISC-V-based system using SystemVerilog and UVM.

The SoC will integrate an open-source RISC-V processor core with data SRAM, a frame buffer, and memory-mapped I/O (MMIO) peripherals. PicoRV32 and Ibex will be evaluated as alternative processor configurations.

## Project Objectives

- Design and verify a memory-mapped address decoder and interconnect.
- Integrate an open-source RISC-V processor core.
- Implement SRAM, frame-buffer, and MMIO target models.
- Develop a UVM testbench with constrained-random stimulus.
- Verify address routing, read/write behavior, boundary conditions, and byte enables.
- Measure functional and code coverage.

## Initial Memory Map

| Address range | Component | Size |
|---|---|---:|
| `0x0000–0x3FFF` | Data SRAM | 16 KB |
| `0x4000–0x5FFF` | Frame buffer | 8 KB |
| `0x6000` onwards | MMIO peripherals | To be defined |

The MMIO address range and peripheral register map will be finalized during implementation.

## Planned Verification

- Directed address-boundary tests
- Read/write transaction tests
- Byte-enable and access-alignment tests
- Constrained-random transaction sequences
- Scoreboard-based data checking
- Assertions and functional coverage
- Code coverage analysis, where supported by the simulator

## Tools

- SystemVerilog
- Universal Verification Methodology (UVM)
- EDA Playground
- A compatible SystemVerilog simulator
- Git and GitHub

## Project Status

**Phase 1:** Address decoder and directed testbench.

**Phase 2:** Memory models and interconnect verification.

**Phase 3:** PicoRV32 and Ibex integration evaluation.

**Phase 4:** UVM constrained-random verification and coverage analysis.

## References

- [PicoRV32 — Official Repository](https://github.com/YosysHQ/picorv32)
- [Ibex — Official Repository](https://github.com/lowRISC/ibex)
- [EDA Playground](https://www.edaplayground.com/)

## Disclaimer

This is an educational M.Tech VLSI project. PicoRV32 and Ibex are third-party open-source projects and retain their respective licenses and copyrights. Any modifications or integrations will be documented separately.
