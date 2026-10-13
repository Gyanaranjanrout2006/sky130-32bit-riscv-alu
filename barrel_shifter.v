`timescale 1ns / 1ps

module barrel_shifter (
    input  wire [31:0] data_in,
    input  wire [4:0]  shamt,     // Shift amount (lower 5 bits of B)
    input  wire [1:0]  shift_type,// 00: SLL, 01: SRL, 10: SRA
    output wire [31:0] data_out
);

    wire [31:0] stage0, stage1, stage2, stage3, stage4;
    wire sign_bit = (shift_type == 2'b10) ? data_in[31] : 1'b0;

    // Shift Left Logical (SLL) logic reverse karke share kiya jata hai
    wire [31:0] reversed_in;
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bit_reversal
            assign reversed_in[i] = data_in[31 - i];
        end
    endgenerate

    wire [31:0] shift_in = (shift_type == 2'b00) ? reversed_in : data_in;

    // Stage 0: Shift by 1 bit
    assign stage0 = shamt[0] ? {{1{sign_bit}}, shift_in[31:1]} : shift_in;

    // Stage 1: Shift by 2 bits
    assign stage1 = shamt[1] ? {{2{sign_bit}}, stage0[31:2]} : stage0;

    // Stage 2: Shift by 4 bits
    assign stage2 = shamt[2] ? {{4{sign_bit}}, stage1[31:4]} : stage1;

    // Stage 3: Shift by 8 bits
    assign stage3 = shamt[3] ? {{8{sign_bit}}, stage2[31:8]} : stage2;

    // Stage 4: Shift by 16 bits
    assign stage4 = shamt[4] ? {{16{sign_bit}}, stage3[31:16]} : stage3;

    // Left shift ke case me output wapas reverse hota hai
    wire [31:0] reversed_out;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bit_reversal_out
            assign reversed_out[i] = stage4[31 - i];
        end
    endgenerate

    assign data_out = (shift_type == 2'b00) ? reversed_out : stage4;

endmodule