// ─────────────────────────────────────────
//  Immediate Generator
//  imm_sel encoding:
//   3'b000 – I-type
//   3'b001 – S-type
//   3'b010 – B-type
//   3'b011 – U-type
//   3'b100 – J-type
// ─────────────────────────────────────────
module imm_gen (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_sel,
    output reg  [31:0] imm_ext
);
    always @(*) begin
        case (imm_sel)
            3'b000: imm_ext = {{20{instr[31]}}, instr[31:20]};                          // I
            3'b001: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};             // S
            3'b010: imm_ext = {{19{instr[31]}}, instr[31], instr[7],                    // B
                                instr[30:25], instr[11:8], 1'b0};
            3'b011: imm_ext = {instr[31:12], 12'b0};                                    // U
            3'b100: imm_ext = {{11{instr[31]}}, instr[31], instr[19:12],                // J
                                instr[20], instr[30:21], 1'b0};
            default: imm_ext = 32'b0;
        endcase
    end
endmodule

// ─────────────────────────────────────────
//  ALU
//  alu_ctrl encoding:
//   4'b0000 – ADD
//   4'b0001 – SUB
//   4'b0010 – AND
//   4'b0011 – OR
//   4'b0100 – XOR
//   4'b0101 – SLL
//   4'b0110 – SRL
//   4'b0111 – SRA
//   4'b1000 – SLT  (signed)
//   4'b1001 – SLTU (unsigned)
//   4'b1010 – LUI pass-b
// ─────────────────────────────────────────
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);
    wire [4:0] shamt = b[4:0];

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            4'b0101: result = a << shamt;
            4'b0110: result = a >> shamt;
            4'b0111: result = $signed(a) >>> shamt;
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            4'b1001: result = (a < b)                   ? 32'b1 : 32'b0;
            4'b1010: result = b;                          // LUI / AUIPC
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);
endmodule

// ─────────────────────────────────────────
//  Data Memory  (256 x 32-bit words)
//  Supports byte/half/word load & store
// ─────────────────────────────────────────
module data_mem (
    input  wire        clk,
    input  wire        we,
    input  wire        re,
    input  wire [2:0]  funct3,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);
    reg [31:0] mem [0:255];
    wire [7:0] word_addr = addr[9:2];

    // Write (byte/half/word)
    always @(posedge clk) begin
        if (we) begin
            case (funct3)
                3'b000: begin   // SB
                    case (addr[1:0])
                        2'b00: mem[word_addr][7:0]   <= wdata[7:0];
                        2'b01: mem[word_addr][15:8]  <= wdata[7:0];
                        2'b10: mem[word_addr][23:16] <= wdata[7:0];
                        2'b11: mem[word_addr][31:24] <= wdata[7:0];
                    endcase
                end
                3'b001: begin   // SH
                    case (addr[1])
                        1'b0: mem[word_addr][15:0]  <= wdata[15:0];
                        1'b1: mem[word_addr][31:16] <= wdata[15:0];
                    endcase
                end
                3'b010: mem[word_addr] <= wdata;   // SW
                default: mem[word_addr] <= wdata;
            endcase
        end
    end

    // Read (byte/half/word, signed & unsigned)
    always @(*) begin
        if (re) begin
            case (funct3)
                3'b000: begin   // LB
                    case (addr[1:0])
                        2'b00: rdata = {{24{mem[word_addr][7]}},  mem[word_addr][7:0]};
                        2'b01: rdata = {{24{mem[word_addr][15]}}, mem[word_addr][15:8]};
                        2'b10: rdata = {{24{mem[word_addr][23]}}, mem[word_addr][23:16]};
                        2'b11: rdata = {{24{mem[word_addr][31]}}, mem[word_addr][31:24]};
                    endcase
                end
                3'b001: begin   // LH
                    case (addr[1])
                        1'b0: rdata = {{16{mem[word_addr][15]}}, mem[word_addr][15:0]};
                        1'b1: rdata = {{16{mem[word_addr][31]}}, mem[word_addr][31:16]};
                    endcase
                end
                3'b010: rdata = mem[word_addr];    // LW
                3'b100: begin   // LBU
                    case (addr[1:0])
                        2'b00: rdata = {24'b0, mem[word_addr][7:0]};
                        2'b01: rdata = {24'b0, mem[word_addr][15:8]};
                        2'b10: rdata = {24'b0, mem[word_addr][23:16]};
                        2'b11: rdata = {24'b0, mem[word_addr][31:24]};
                    endcase
                end
                3'b101: begin   // LHU
                    case (addr[1])
                        1'b0: rdata = {16'b0, mem[word_addr][15:0]};
                        1'b1: rdata = {16'b0, mem[word_addr][31:16]};
                    endcase
                end
                default: rdata = mem[word_addr];
            endcase
        end else rdata = 32'b0;
    end
endmodule
