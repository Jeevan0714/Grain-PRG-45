// ============================================================
// 8-bit LFSR with Glitch-Free Enable Control
// fL = L7 ⊕ L5 ⊕ L4 ⊕ L3
// ============================================================

module LFSR (
    input  wire clk,
    input  wire rst,
    input  wire enable,
    output reg  [7:0] L
);

    wire feedback;

    assign feedback = L[7] ^ L[5] ^ L[4] ^ L[3];

    always @(posedge clk) begin
        if (rst)
            L <= 8'b10101101;
        else if (enable)
            L <= {L[6:0], feedback};
    end

endmodule