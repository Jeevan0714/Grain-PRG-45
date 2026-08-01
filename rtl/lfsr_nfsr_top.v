// ============================================================
// Top Integration Module with Low-Power Clock Gating
// ============================================================

module lfsr_nfsr_top (
    input  wire clk,
    input  wire rst,
    input  wire enable,         // Clock Gating Enable (1 = Active, 0 = Gated/Sleep)
    input  wire plaintext,
    output wire ciphertext,
    output wire decrypted_text
);

    // Gated Clock Generation
    wire gated_clk;
    assign gated_clk = clk & enable;

    wire [7:0] L;
    wire [7:0] N;
    wire Z;

    // LFSR
    LFSR lfsr_inst (
        .clk(gated_clk),
        .rst(rst),
        .L(L)
    );

    // NFSR
    NFSR nfsr_inst (
        .clk(gated_clk),
        .rst(rst),
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