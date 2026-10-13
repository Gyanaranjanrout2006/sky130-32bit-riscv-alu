# 32-bit RISC-V ALU - ASIC Physical Design (RTL-to-GDSII)

Automated RTL-to-GDSII physical implementation of a 32-bit RISC-V execution unit targeting the **SkyWater 130nm (`sky130A`)** open-source technology node using the **OpenLane** flow.

---

## 📌 Layout Preview
![RISC-V ALU Silicon Layout](layout.png)

---

## ⚙️ Project Overview & Architecture
This design implements a high-performance 32-bit Arithmetic Logic Unit supporting core operations from the **RV32I** and **RV32M** RISC-V instruction set architectures:

- **Arithmetic Unit:** High-speed 32-bit carry-lookahead adder hierarchy (`fast_adder_32bit.v`, `cla_4bit.v`).
- **Barrel Shifter:** Multi-bit logarithmic shifter supporting Logical Left (SLL), Logical Right (SRL), and Arithmetic Right (SRA) shifts (`barrel_shifter.v`).
- **Hardware Divider:** Iterative shift-subtract sequential integer divider unit (`riscv_divider.v`).
- **Top Integration:** Master ALU top module managing opcode decoding and execution paths (`riscv_alu_top_m.v`).

---

## 📊 Physical Design & Sign-Off Summary

| Parameter | Specification / Result |
| :--- | :--- |
| **Technology Node** | SkyWater 130nm (`sky130A`) |
| **Standard Cell Library** | `sky130_fd_sc_hd` |
| **Core Area Dimensions** | ~495 µm × 495 µm |
| **Target Clock Period** | 25.0 ns (40 MHz) |
| **Magic DRC Violations** | 0 (Clean Sign-off) |
| **Setup Slack Violations** | 0 violations (Timing Met) |
| **Hold Slack Violations** | 0 violations (Timing Met) |
| **Routing Status** | No DRC violations after detailed routing (TritonRoute) |

---

## 🛠️ Tools Used
- **RTL Synthesis:** Yosys
- **Floorplan & Placement:** OpenROAD
- **Detailed Routing:** TritonRoute
- **Sign-off DRC / GDSII Streaming:** Magic VLSI
- **Layout Visualization:** KLayout

---

## 🚀 How to Reproduce Flow
1. Clone OpenLane and setup the `sky130A` PDK.
2. Place the Verilog source files into `designs/my_alu/src/` and include `config.json`.
3. Launch OpenLane environment and run:
   ```bash
   make mount
   ./flow.tcl -design my_alu
