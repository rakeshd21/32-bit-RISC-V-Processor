`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2026 22:33:48
// Design Name: 
// Module Name: tb_riscv
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
//  Testbench for RISC-V Single-Cycle CPU
// ─────────────────────────────────────────
`timescale 1ns/1ps

module tb_riscv;

    reg clk, rst;

    riscv_top DUT (
        .clk (clk),
        .rst (rst)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Dump waveforms
    initial begin
        $dumpfile("riscv.vcd");
        $dumpvars(0, tb_riscv);
    end

    initial begin
        rst = 1;
        #15;
        rst = 0;
        #500;   // run for 50 cycles
        $finish;
    end

    // Monitor PC and instruction each cycle
    initial begin
        $monitor("Time=%0t  PC=%08h  INSTR=%08h",
                  $time,
                  DUT.pc,
                  DUT.instr);
    end

endmodule

