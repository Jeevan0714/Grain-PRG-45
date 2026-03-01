`timescale 1ns/1ps

module TB;

reg clk;
reg rst;
reg plaintext;

wire ciphertext;
wire decrypted_text;

// Instantiate Top Module
lfsr_nfsr_top dut (
    .clk(clk),
    .rst(rst),
    .plaintext(plaintext),
    .ciphertext(ciphertext),
    .decrypted_text(decrypted_text)
);

// Clock Generation
always #5 clk = ~clk;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, TB);

    clk = 0;
    rst = 1;
    plaintext = 0;

    #10 rst = 0;

    #10 plaintext = 1;
    #20 plaintext = 0;
    #20 plaintext = 1;
    #20 plaintext = 1;
    #20 plaintext = 0;

    #50 $finish;
end

endmodule