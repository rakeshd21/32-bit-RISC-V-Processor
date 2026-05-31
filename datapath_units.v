`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2026 22:25:17
// Design Name: 
// Module Name: datapath_units
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
//  PC Register
// ─────────────────────────────────────────
module pc_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    always @(posedge clk or posedge rst)
        if (rst) pc <= 32'h0000_0000;
        else     pc <= pc_next;
endmodule

// ─────────────────────────────────────────
//  Instruction Memory  (256 x 32-bit words)
// ─────────────────────────────────────────
module instr_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];

    initial $readmemh("C:/Users/kiran/project_1/project_1.srcs/sources_1/new/program.hex", mem);

    assign instr = mem[addr[9:2]];   // word-aligned access
endmodule

// ─────────────────────────────────────────
//  Register File  (32 x 32-bit)
// ─────────────────────────────────────────
module reg_file (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] wdata,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2
);
    reg [31:0] regs [0:31];
    integer i;

    initial for (i = 0; i < 32; i = i + 1) regs[i] = 32'b0;

    always @(posedge clk)
        if (we && rd != 5'b0)
            regs[rd] <= wdata;

    assign rdata1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign rdata2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];
endmodule

