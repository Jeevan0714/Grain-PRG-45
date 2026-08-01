// ============================================================
// Top Integration Module with Glitch-Free Clock Gating Enable
// ============================================================

module lfsr_nfsr_top (
    input  wire clk,
    input  wire rst,
    input  wire enable,         // Enable Control (1 = Active, 0 = Gated/Sleep)
    input  wire plaintext,
    output wire ciphertext,
    output wire decrypted_text
);

    wire [7:0] L;
    wire [7:0] N;
    wire Z;

    // LFSR with enable control
    LFSR lfsr_inst (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .L(L)
    );

    // NFSR with enable control
    NFSR nfsr_inst (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .L4(L[4]),
        .N(N)
    );

    // Keystream
    KEYSTREAM ks_inst (
        .L(L),
        .N(N),
        .Z(Z)
    );

    // Encryption
    ENCRYPT enc_inst (
        .plaintext(plaintext),
        .Z(Z),
        .ciphertext(ciphertext)
    );

    // Decryption
    DECRYPT dec_inst (
        .ciphertext(ciphertext),
        .Z(Z),
        .plaintext_out(decrypted_text)
    );

endmodule