`timescale 1ns/1ps

module TB;

reg clk;
reg rst;
reg enable;
reg plaintext;

wire ciphertext;
wire decrypted_text;

// Instantiate Top Module
lfsr_nfsr_top dut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .plaintext(plaintext),
    .ciphertext(ciphertext),
    .decrypted_text(decrypted_text)
);

// Clock Generation
always #5 clk = ~clk;

initial begin
    $dumpfile("flow_45nm_open_source/results/wave.vcd");
    $dumpvars(0, TB);

    clk = 0;
    rst = 1;
    enable = 0; // Sleep mode
    plaintext = 0;

    #10 rst = 0;
    #10 enable = 1; // Active mode

    #10 plaintext = 1;
    #20 plaintext = 0;
    #20 plaintext = 1;
    #20 plaintext = 1;
    #20 plaintext = 0;

    #20 enable = 0; // Gated Sleep mode
    #40 enable = 1; // Wake up

    #50 $finish;
end

endmodule