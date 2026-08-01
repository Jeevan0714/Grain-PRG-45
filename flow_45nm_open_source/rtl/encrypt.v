// ============================================================
// Encryption
// C = P ⊕ Z
// ============================================================

module ENCRYPT (
    input  wire plaintext,
    input  wire Z,
    output wire ciphertext
);

    assign ciphertext = plaintext ^ Z;

endmodule