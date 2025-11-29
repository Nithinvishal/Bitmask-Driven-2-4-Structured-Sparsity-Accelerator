`timescale 1ns / 1ps

module sparse_pe (
    input wire clk,
    input wire rst_n,
    
    // Inputs
    input wire [15:0] packed_activations, // Four 4-bit inputs packed together
    input wire [3:0]  mask,               // The sparsity mask (e.g., 1001)
    input wire [7:0]  weight_top,         // First kept weight
    input wire [7:0]  weight_bot,         // Second kept weight
    
    // Output
    output reg [31:0] result
);

    // 1. Unpack Activations
    wire [3:0] act [0:3];
    assign act[0] = packed_activations[3:0];
    assign act[1] = packed_activations[7:4];
    assign act[2] = packed_activations[11:8];
    assign act[3] = packed_activations[15:12];

    // 2. Decode Mask (Priority Encoder)
    // Determine which activation index matches the kept weights
    reg [1:0] idx_top;
    reg [1:0] idx_bot;
    
    always @(*) begin
        // Default
        idx_top = 0; idx_bot = 0;
        
        case (mask)
            4'b0011: begin idx_top = 1; idx_bot = 0; end
            4'b0101: begin idx_top = 2; idx_bot = 0; end
            4'b1001: begin idx_top = 3; idx_bot = 0; end
            4'b0110: begin idx_top = 2; idx_bot = 1; end
            4'b1010: begin idx_top = 3; idx_bot = 1; end
            4'b1100: begin idx_top = 3; idx_bot = 2; end
            default: begin idx_top = 0; idx_bot = 0; end
        endcase
    end

    // 3. MUX Selection
    reg [3:0] operand_a_top;
    reg [3:0] operand_a_bot;
    
    always @(*) begin
        operand_a_top = act[idx_top];
        operand_a_bot = act[idx_bot];
    end

    // 4. Multiply and Accumulate
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
        end else begin
            result <= (weight_top * operand_a_top) + (weight_bot * operand_a_bot);
        end
    end

endmodule