`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2026 22:27:55
// Design Name: 
// Module Name: riscv_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// RISC-V Single-Cycle Processor (RV32I)
// Top-level module

module riscv_top (
    input  wire        clk,
    input  wire        rst
);
    wire [31:0] pc, pc_next, pc_plus4, pc_branch;
    wire [31:0] instr;
    wire [31:0] reg_rdata1, reg_rdata2, reg_wdata;
    wire [31:0] imm_ext;
    wire [31:0] alu_src_b, alu_result;
    wire [31:0] mem_rdata;
    wire [31:0] alu_or_mem;

    wire        reg_write, alu_src, mem_write, mem_read;
    wire        mem_to_reg, branch, jump, zero;
    wire [3:0]  alu_ctrl;
    wire [2:0]  imm_sel;
    wire        pc_src;

    // PC Register
    pc_reg PC (
        .clk     (clk),
        .rst     (rst),
        .pc_next (pc_next),
        .pc      (pc)
    );

    // Instruction Memory
    instr_mem IMEM (
        .addr  (pc),
        .instr (instr)
    );

    // Control Unit
    control_unit CU (
        .opcode    (instr[6:0]),
        .funct3    (instr[14:12]),
        .funct7_5  (instr[30]),
        .reg_write (reg_write),
        .alu_src   (alu_src),
        .mem_write (mem_write),
        .mem_read  (mem_read),
        .mem_to_reg(mem_to_reg),
        .branch    (branch),
        .jump      (jump),
        .alu_ctrl  (alu_ctrl),
        .imm_sel   (imm_sel)
    );

    // Register File
    reg_file RF (
        .clk    (clk),
        .we     (reg_write),
        .rs1    (instr[19:15]),
        .rs2    (instr[24:20]),
        .rd     (instr[11:7]),
        .wdata  (reg_wdata),
        .rdata1 (reg_rdata1),
        .rdata2 (reg_rdata2)
    );

    // Immediate Extension
    imm_gen IG (
        .instr   (instr),
        .imm_sel (imm_sel),
        .imm_ext (imm_ext)
    );

    // ALU Source Mux
    assign alu_src_b = alu_src ? imm_ext : reg_rdata2;

    // ALU
    alu ALU (
        .a        (reg_rdata1),
        .b        (alu_src_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (zero)
    );

    // Data Memory
    data_mem DMEM (
        .clk    (clk),
        .we     (mem_write),
        .re     (mem_read),
        .funct3 (instr[14:12]),
        .addr   (alu_result),
        .wdata  (reg_rdata2),
        .rdata  (mem_rdata)
    );

    // WB Mux: ALU result or memory data
    assign alu_or_mem = mem_to_reg ? mem_rdata : alu_result;
    // WB Mux2: normal WB or PC+4 (for JAL/JALR)
    assign reg_wdata  = jump ? pc_plus4 : alu_or_mem;

    // Branch / Jump PC logic
    assign pc_plus4  = pc + 32'd4;
    assign pc_branch = pc + imm_ext;          // branch target
    assign pc_src    = (branch & zero) | jump;

    // For JALR: target = rs1 + imm (already in alu_result when jump)
    // Simple mux: if jump use alu_result for JALR, else pc_branch for JAL/BEQ
    wire is_jalr = (instr[6:0] == 7'b1100111);
    assign pc_next = ~pc_src      ? pc_plus4   :
                     is_jalr      ? alu_result  :
                                    pc_branch;

endmodule

