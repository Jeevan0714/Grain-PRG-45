// ============================================================
// Decryption
// P = C ⊕ Z
// ============================================================

module DECRYPT (
    input  wire ciphertext,
    input  wire Z,
    output wire plaintext_out
);

    assign plaintext_out = ciphertext ^ Z;

endmodule