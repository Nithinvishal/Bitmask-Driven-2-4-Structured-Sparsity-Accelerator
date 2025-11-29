module dense_pe (
    input clk, rst_n,
    input [15:0] inputs,
    input [15:0] weights,
    output reg [31:0] result
);
    wire [3:0] a0, a1, a2, a3;
    wire [3:0] w0, w1, w2, w3;
    assign a0 = inputs[3:0];   assign w0 = weights[3:0];
    assign a1 = inputs[7:4];   assign w1 = weights[7:4];
    assign a2 = inputs[11:8];  assign w2 = weights[11:8];
    assign a3 = inputs[15:12]; assign w3 = weights[15:12];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) result <= 0;
        else result <= (a0 * w0) + (a1 * w1) + (a2 * w2) + (a3 * w3);
    end
endmodule
