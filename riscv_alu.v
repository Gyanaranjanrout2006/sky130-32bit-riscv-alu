`timescale 1ns / 1ps

module riscv_alu (
    input  wire [31:0] A,            // Operand 1
    input  wire [31:0] B,            // Operand 2
    input  wire [3:0]  ALU_Control,  // Control signal (from decoder)
    output reg  [31:0] ALU_Result,   // 32-bit computation result
    output wire        Zero          // Zero flag (Branching ke liye use hota hai)
);

    // RISC-V RV32I ALU Operations
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010; // Shift Left Logical
    localparam ALU_SLT  = 4'b0011; // Set Less Than (Signed)
    localparam ALU_SLTU = 4'b0100; // Set Less Than (Unsigned)
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110; // Shift Right Logical
    localparam ALU_SRA  = 4'b0111; // Shift Right Arithmetic
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;

    always @(*) begin
        case (ALU_Control)
            ALU_ADD:  ALU_Result = A + B;
            ALU_SUB:  ALU_Result = A - B;
            ALU_SLL:  ALU_Result = A << B[4:0];                          // Shift by lower 5 bits
            ALU_SLT:  ALU_Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // Signed comparison
            ALU_SLTU: ALU_Result = (A < B) ? 32'd1 : 32'd0;             // Unsigned comparison
            ALU_XOR:  ALU_Result = A ^ B;
            ALU_SRL:  ALU_Result = A >> B[4:0];                         // Logical shift right
            ALU_SRA:  ALU_Result = $signed(A) >>> B[4:0];               // Arithmetic shift right (sign bit preserved)
            ALU_OR:   ALU_Result = A | B;
            ALU_AND:  ALU_Result = A & B;
            default:  ALU_Result = 32'd0;
        endcase
    end

    // Zero flag high tabhi hota hai jab result zero ho (Branch-equal check ke liye)
    assign Zero = (ALU_Result == 32'd0);

endmodule