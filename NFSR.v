// ============================================================
// 8-bit NFSR
// fN = N7 ⊕ (N5·N3) ⊕ ((N2·N1) ⊕ L4)
// ============================================================

module NFSR (
    input  wire clk,
    input  wire rst,
    input  wire L4,
    output reg  [7:0] N
);

    wire nonlinear1;
    wire nonlinear2;
    wire feedback;

    assign nonlinear1 = N[5] & N[3];
    assign nonlinear2 = (N[2] & N[1]) ^ L4;

    assign feedback = N[7] ^ nonlinear1 ^ nonlinear2;

    always @(posedge clk) begin
        if (rst)
            N <= 8'b11011010;
        else
            N <= {N[6:0], feedback};
    end

endmodule