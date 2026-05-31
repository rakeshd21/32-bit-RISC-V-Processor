<img width="1050" height="826" alt="WhatsApp Image 2026-05-31 at 1 18 46 PM" src="https://github.com/user-attachments/assets/d82d6fe4-afed-4691-b49d-880bc5be1bcd" /># 32-bit RISC-V Processor

A fully functional 32-bit RISC-V processor implemented in Verilog (RTL design), supporting the RV32I base integer instruction set. This project includes the complete datapath, control unit, ALU, memory, and a testbench for simulation and verification.

---

## 📁 Repository Structure

```
32-bit-RISC-V-Processor/
├── alu_mem.v          # ALU and data memory module
├── control_unit.v     # Control unit (instruction decode & control signal generation)
├── datapath_units.v   # Datapath components (registers, MUXes, adders, etc.)
├── riscv_top.v        # Top-level module integrating all components
├── tb_riscv.v         # Testbench for simulation
└── program.hex        # Machine code program loaded into instruction memory
```

---

## 🏗️ Architecture Overview



The processor follows a classic **single-cycle / pipelined RISC-V** architecture with the following key components:

### 1. `riscv_top.v` — Top-Level Module
Instantiates and connects all sub-modules:
- Instruction memory
- Program counter (PC) logic
- Datapath units
- Control unit
- ALU & data memory

### 2. `control_unit.v` — Control Unit
Decodes the 32-bit instruction and generates control signals for:
- ALU operation selection
- Register file write enable
- Memory read/write control
- Branch/jump decision logic
- Immediate generation

### 3. `datapath_units.v` — Datapath
Contains:
- 32×32 Register File (x0–x31)
- Program Counter (PC) with increment and branch logic
- Immediate value sign-extension unit
- MUX selectors for ALU inputs and write-back

### 4. `alu_mem.v` — ALU & Data Memory
- **ALU**: Supports ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA operations
- **Data Memory**: Word-addressable memory for load/store instructions

### 5. `program.hex` — Program File
Hex-encoded RISC-V machine instructions loaded into instruction memory at simulation start.

### 6. `tb_riscv.v` — Testbench
Drives the clock and reset, loads `program.hex`, and monitors register/memory output for verification.

---

## 🔧 Supported Instructions (RV32I Subset)

| Type | Instructions |
|------|-------------|
| R-Type | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`, `SLL`, `SRL`, `SRA` |
| I-Type | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `LW` |
| S-Type | `SW` |
| B-Type | `BEQ`, `BNE`, `BLT`, `BGE` |
| U-Type | `LUI`, `AUIPC` |
| J-Type | `JAL`, `JALR` |

---

## 🚀 Getting Started

### Prerequisites
- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`) — for simulation
- [GTKWave](http://gtkwave.sourceforge.net/) — for waveform viewing (optional)

### Simulate

```bash
# Compile
iverilog -o riscv_sim tb_riscv.v riscv_top.v control_unit.v datapath_units.v alu_mem.v

# Run simulation
vvp riscv_sim

# View waveform (if VCD dump is enabled in testbench)
gtkwave dump.vcd
```

---

## 📊 Simulation & Verification

The testbench (`tb_riscv.v`) loads `program.hex` into instruction memory and runs the processor for a set number of clock cycles. You can monitor:
- Register file values after each instruction
- Memory read/write operations
- PC progression (sequential and branch/jump)

---

## 📌 Design Notes

- **Word-addressed** data memory
- **Harvard architecture** — separate instruction and data memory
- **Little-endian** byte ordering
- **x0 register** is hardwired to zero as per the RISC-V specification

---

## 👤 Author

**Rakesh** — [rakeshd21](https://github.com/rakeshd21)

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
