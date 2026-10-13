`timescale 1ns / 1ps

module riscv_alu_top_m (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [4:0]  ALU_Control, // 5-bit control for full RV32I + RV32M
    input  wire        start_div,   // Trigger for divide operations
    output reg  [31:0] ALU_Result,
    output wire        Zero,
    output wire        Negative,
    output wire        Overflow,
    output wire        div_ready,   // Division valid output
    output wire        div_busy     // Division in progress
);

    // RV32I & Multiplication results from riscv_alu_adv
    wire [31:0] alu_adv_res;
    wire        adv_zero, adv_neg, adv_ovf;

    // Sub-module: Base ALU + Multiplier + Barrel Shifter
    riscv_alu_adv u_alu_core (
        .A(A),
        .B(B),
        .ALU_Control(ALU_Control[3:0]),
        .ALU_Result(alu_adv_res),
        .Zero(adv_zero),
        .Negative(adv_neg),
        .Overflow(adv_ovf)
    );

    // Sub-module: Iterative Hardware Divider
    wire [31:0] div_res;
    riscv_divider u_divider (
        .clk(clk),
        .rst(rst),
        .start(start_div),
        .div_op(ALU_Control[2:0]),
        .dividend_in(A),
        .divisor_in(B),
        .result(div_res),
        .ready(div_ready),
        .busy(div_busy)
    );

    // Output MUX: Division operation ho toh Divider ka output select karega
    wire is_div_op = ALU_Control[4]; // Bit 4 represents Division family

    always @(*) begin
        if (is_div_op)
            ALU_Result = div_res;
        else
            ALU_Result = alu_adv_res;
    end

    assign Zero     = (ALU_Result == 32'd0);
    assign Negative = ALU_Result[31];
    assign Overflow = is_div_op ? 1'b0 : adv_ovf;

endmodule