# FPGA Biometric Lock

Facial-recognition door lock on an FPGA – hepia, FPGA project, 2025.
Team project: **Adrian Spycher** & Valentin Bernillo.

## Overview

A biometric unlocking system on the **Digilent Nexys Video** board (Xilinx Artix-7):

1. A **VCNL4040 proximity sensor** detects someone approaching and raises an **interrupt**.
2. A **camera** captures the face.
3. The **LBPH** (Local Binary Pattern Histogram) face-recognition algorithm, **implemented in VHDL**, compares it with authorised faces.
4. If the user is recognised, the lock (electromagnet) is released and a green LED turns on.

A **MicroBlaze** soft-core handles the overall control and talks to the custom peripherals through **AXI4-Lite** interfaces.

## Repository layout

| Folder | Content |
|---|---|
| `circuits/src/hdl/` | VHDL design: LBPH pipeline (convolution, pixel encoder, histogram, comparison), top level |
| `circuits/src/sim/` | Testbenches for every block (LBPH, camera, proximity sensor, lock) |
| `circuits/scripts/` | Tcl scripts to recreate the Vivado project and block designs |
| `circuits/vitis_src/` | MicroBlaze firmware (Vitis), interrupt-driven GPIO |
| `programs/` | C reference model of LBPH used to validate the hardware |
| `specification/` | Specification sources (Typst) |
| `raport.pdf`, `presentation.pdf` | Final report (FR) and slides |

## Build

```bash
cd circuits
make create-project   # recreates the Vivado project from the Tcl scripts
make open-project
```

Requires Vivado / Vitis (2023+).

## Tech

VHDL · Vivado · Vitis · MicroBlaze · AXI4-Lite · Interrupts · C · Tcl

French version of this README: [README.fr.md](README.fr.md)
