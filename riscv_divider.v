`timescale 1ns / 1ps

module riscv_divider (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,        // Division start trigger
    input  wire [2:0]  div_op,       // 000: DIV, 001: DIVU, 010: REM, 011: REMU
    input  wire [31:0] dividend_in,  // Operand A
    input  wire [31:0] divisor_in,   // Operand B
    output reg  [31:0] result,       // Quotient or Remainder
    output reg         ready,        // 1 when result is valid
    output reg         busy          // 1 while computing (32 cycles)
);

    // States
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam FINISH  = 2'b10;

    reg [1:0]  state;
    reg [5:0]  count;
    reg [64:0] working_reg; // 33-bit Remainder + 32-bit Quotient
    reg [31:0] divisor_reg;
    reg        sign_quotient;
    reg        sign_remainder;
    reg [2:0]  op_reg;

    wire is_signed = (div_op == 3'b000) || (div_op == 3'b010);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= IDLE;
            ready          <= 1'b0;
            busy           <= 1'b0;
            result         <= 32'd0;
            count          <= 6'd0;
            working_reg    <= 65'd0;
            divisor_reg    <= 32'd0;
            sign_quotient  <= 1'b0;
            sign_remainder <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    if (start) begin
                        busy   <= 1'b1;
                        op_reg <= div_op;

                        // RISC-V Corner Case 1: Division by Zero
                        if (divisor_in == 32'd0) begin
                            state <= FINISH;
                            if (div_op == 3'b000 || div_op == 3'b001)
                                result <= 32'hFFFFFFFF; // DIV / DIVU by 0 -> -1
                            else
                                result <= dividend_in;   // REM / REMU by 0 -> A
                        end
                        // RISC-V Corner Case 2: Signed Overflow (-2^31 / -1)
                        else if (is_signed && (dividend_in == 32'h80000000) && (divisor_in == 32'hFFFFFFFF)) begin
                            state <= FINISH;
                            if (div_op == 3'b000)
                                result <= 32'h80000000; // -2^31
                            else
                                result <= 32'd0;        // Remainder = 0
                        end else begin
                            state <= COMPUTE;
                            count <= 6'd32;

                            // Signs calculate karna
                            sign_quotient  <= is_signed && (dividend_in[31] ^ divisor_in[31]);
                            sign_remainder <= is_signed && dividend_in[31];

                            // Absolute values load karna
                            divisor_reg <= (is_signed && divisor_in[31]) ? (-divisor_in) : divisor_in;
                            working_reg <= {33'd0, (is_signed && dividend_in[31]) ? (-dividend_in) : dividend_in};
                        end
                    end
                end

                COMPUTE: begin
                    if (count > 0) begin
                        // Shift left 1 bit
                        if ({working_reg[63:31]} >= {1'b0, divisor_reg}) begin
                            working_reg <= {working_reg[63:31] - {1'b0, divisor_reg}, working_reg[30:0], 1'b1};
                        end else begin
                            working_reg <= {working_reg[63:0], 1'b0};
                        end
                        count <= count - 1;
                    end else begin
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    busy  <= 1'b0;
                    ready <= 1'b1;

                    // Output select based on DIV / REM
                    if (op_reg == 3'b000) // Signed DIV
                        result <= sign_quotient ? -working_reg[31:0] : working_reg[31:0];
                    else if (op_reg == 3'b001) // Unsigned DIV
                        result <= working_reg[31:0];
                    else if (op_reg == 3'b010) // Signed REM
                        result <= sign_remainder ? -working_reg[63:32] : working_reg[63:32];
                    else // Unsigned REM (3'b011)
                        result <= working_reg[63:32];

                    state <= IDLE;
                end
            endcase
        end
    end

endmodule