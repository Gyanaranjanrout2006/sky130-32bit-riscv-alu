`timescale 1ns / 1ps

module fast_adder_32bit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        sub_mode, // 0: ADD, 1: SUB
    output wire [31:0] Sum,
    output wire        Cout,
    output wire        Overflow
);

    // Agar sub_mode 1 hai to B ko invert kar dete hain (1's complement)
    wire [31:0] B_mod = sub_mode ? ~B : B;
    // Aur Cin ko 1 dete hain (2's complement addition: A + ~B + 1)
    wire        Cin   = sub_mode;

    wire [7:0] c_in_block;
    wire [7:0] c_out_block;
    wire [7:0] pg, gg;

    assign c_in_block[0] = Cin;
    assign c_in_block[1] = gg[0] | (pg[0] & c_in_block[0]);
    assign c_in_block[2] = gg[1] | (pg[1] & c_in_block[1]);
    assign c_in_block[3] = gg[2] | (pg[2] & c_in_block[2]);
    assign c_in_block[4] = gg[3] | (pg[3] & c_in_block[3]);
    assign c_in_block[5] = gg[4] | (pg[4] & c_in_block[4]);
    assign c_in_block[6] = gg[5] | (pg[5] & c_in_block[5]);
    assign c_in_block[7] = gg[6] | (pg[6] & c_in_block[6]);

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : cla_gen
            cla_4bit u_cla (
                .A(A[i*4 +: 4]),
                .B(B_mod[i*4 +: 4]),
                .Cin(c_in_block[i]),
                .Sum(Sum[i*4 +: 4]),
                .Cout(c_out_block[i]),
                .PG(pg[i]),
                .GG(gg[i])
            );
        end
    endgenerate

    assign Cout = c_out_block[7];
    // Signed Overflow: Agar dono inputs ka sign same ho aur sum ka alag ho jaye
    assign Overflow = (~(A[31] ^ B_mod[31])) & (A[31] ^ Sum[31]);

endmodule