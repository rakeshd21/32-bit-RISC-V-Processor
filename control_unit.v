`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2026 22:32:00
// Design Name: 
// Module Name: control_unit
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


// ─────────────────────────────────────────
//  Control Unit
//  Decodes opcode + funct3 + funct7[5]
//  into all control signals.
// ─────────────────────────────────────────
module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire       funct7_5,

    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_write,
    output reg        mem_read,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        jump,
    output reg  [3:0] alu_ctrl,
    output reg  [2:0] imm_sel
);

    // Opcode constants
    localparam OP_R      = 7'b0110011;
    localparam OP_I_ALU  = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;

    always @(*) begin
        // Defaults
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_ctrl   = 4'b0000;   // ADD
        imm_sel    = 3'b000;    // I-type

        case (opcode)
            // ── R-type ──────────────────────────────
            OP_R: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = funct7_5 ? 4'b0001 : 4'b0000; // SUB / ADD
                    3'b001: alu_ctrl = 4'b0101;  // SLL
                    3'b010: alu_ctrl = 4'b1000;  // SLT
                    3'b011: alu_ctrl = 4'b1001;  // SLTU
                    3'b100: alu_ctrl = 4'b0100;  // XOR
                    3'b101: alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110; // SRA / SRL
                    3'b110: alu_ctrl = 4'b0011;  // OR
                    3'b111: alu_ctrl = 4'b0010;  // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            // ── I-type ALU ──────────────────────────
            OP_I_ALU: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 3'b000;
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000;  // ADDI
                    3'b001: alu_ctrl = 4'b0101;  // SLLI
                    3'b010: alu_ctrl = 4'b1000;  // SLTI
                    3'b011: alu_ctrl = 4'b1001;  // SLTIU
                    3'b100: alu_ctrl = 4'b0100;  // XORI
                    3'b101: alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110; // SRAI / SRLI
                    3'b110: alu_ctrl = 4'b0011;  // ORI
                    3'b111: alu_ctrl = 4'b0010;  // ANDI
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            // ── Load ────────────────────────────────
            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                imm_sel    = 3'b000;
                alu_ctrl   = 4'b0000;  // ADD (addr calc)
            end

            // ── Store ───────────────────────────────
            OP_STORE: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                imm_sel   = 3'b001;
                alu_ctrl  = 4'b0000;  // ADD (addr calc)
            end

            // ── Branch ──────────────────────────────
            OP_BRANCH: begin
                branch  = 1'b1;
                imm_sel = 3'b010;
                case (funct3)
                    3'b000: alu_ctrl = 4'b0001;  // BEQ  → SUB, check zero
                    3'b001: alu_ctrl = 4'b0001;  // BNE  → SUB, check ~zero (handled in top)
                    3'b100: alu_ctrl = 4'b1000;  // BLT
                    3'b101: alu_ctrl = 4'b1000;  // BGE
                    3'b110: alu_ctrl = 4'b1001;  // BLTU
                    3'b111: alu_ctrl = 4'b1001;  // BGEU
                    default: alu_ctrl = 4'b0001;
                endcase
            end

            // ── JAL ─────────────────────────────────
            OP_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                imm_sel   = 3'b100;
                alu_ctrl  = 4'b0000;
            end

            // ── JALR ────────────────────────────────
            OP_JALR: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                jump      = 1'b1;
                imm_sel   = 3'b000;
                alu_ctrl  = 4'b0000;  // ADD rs1+imm → jump target
            end

            // ── LUI ─────────────────────────────────
            OP_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 3'b011;
                alu_ctrl  = 4'b1010;  // pass-b (imm)
            end

            // ── AUIPC ───────────────────────────────
            OP_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 3'b011;
                alu_ctrl  = 4'b0000;  // ADD pc+imm (pc fed as 'a' in top)
            end

            default: begin end
        endcase
    end
endmodule

