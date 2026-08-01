// ============================================================
// Output Logic Z
// Z = L2 ⊕ N3 ⊕ (L7·N4) ⊕ (L1·N6)
// ============================================================

module KEYSTREAM (
    input  wire [7:0] L,
    input  wire [7:0] N,
    output wire Z
);

    assign Z = L[2] ^
               N[3] ^
               (L[7] & N[4]) ^
               (L[1] & N[6]);

endmodule