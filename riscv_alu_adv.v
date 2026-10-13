`timescale 1ns / 1ps

module riscv_alu_adv (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALU_Control,
    output reg  [31:0] ALU_Result,
    output wire        Zero,
    output wire        Negative,
    output reg         Overflow
);

    // RV32I + RV32M Extension Control Codes
    localparam ALU_ADD   = 4'b0000;
    localparam ALU_SUB   = 4'b0001;
    localparam ALU_SLL   = 4'b0010;
    localparam ALU_SLT   = 4'b0011;
    localparam ALU_SLTU  = 4'b0100;
    localparam ALU_XOR   = 4'b0101;
    localparam ALU_SRL   = 4'b0110;
    localparam ALU_SRA   = 4'b0111;
    localparam ALU_OR    = 4'b1000;
    localparam ALU_AND   = 4'b1001;
    localparam ALU_MUL   = 4'b1010; // MUL (Lower 32-bit)
    localparam ALU_MULH  = 4'b1011; // MULH (Upper 32-bit Signed)
    localparam ALU_MULHU = 4'b1100; // MULHU (Upper 32-bit Unsigned)

    // Barrel Shifter Instantiation
    reg [1:0] shift_type;
    wire [31:0] shift_res;

    barrel_shifter u_bs (
        .data_in(A),
        .shamt(B[4:0]),
        .shift_type(shift_type),
        .data_out(shift_res)
    );

    // Multiplication 64-bit Logic
    wire signed [63:0] mul_signed   = $signed(A) * $signed(B);
    wire        [63:0] mul_unsigned = A * B;

    always @(*) begin
        shift_type = 2'b01;
        Overflow   = 1'b0;

        case (ALU_Control)
            ALU_ADD: begin
                ALU_Result = A + B;
                // Signed addition overflow check
                Overflow = (~(A[31] ^ B[31])) & (A[31] ^ ALU_Result[31]);
            end
            ALU_SUB: begin
                ALU_Result = A - B;
                // Signed subtraction overflow check
                Overflow = (A[31] ^ B[31]) & (A[31] ^ ALU_Result[31]);
            end

            // Barrel Shifter Paths
            ALU_SLL: begin
                shift_type = 2'b00;
                ALU_Result = shift_res;
            end
            ALU_SRL: begin
                shift_type = 2'b01;
                ALU_Result = shift_res;
            end
            ALU_SRA: begin
                shift_type = 2'b10;
                ALU_Result = shift_res;
            end

            ALU_SLT:   ALU_Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            ALU_SLTU:  ALU_Result = (A < B) ? 32'd1 : 32'd0;
            ALU_XOR:   ALU_Result = A ^ B;
            ALU_OR:    ALU_Result = A | B;
            ALU_AND:   ALU_Result = A & B;

            // 'M' Extension Multiplications
            ALU_MUL:   ALU_Result = mul_signed[31:0];   // Lower 32 bits
            ALU_MULH:  ALU_Result = mul_signed[63:32];  // Upper 32 bits signed
            ALU_MULHU: ALU_Result = mul_unsigned[63:32];// Upper 32 bits unsigned

            default:   ALU_Result = 32'd0;
        endcase
    end

    assign Zero     = (ALU_Result == 32'd0);
    assign Negative = ALU_Result[31];

endmodule