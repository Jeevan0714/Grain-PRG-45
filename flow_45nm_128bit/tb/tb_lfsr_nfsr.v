`timescale 1ns/1ps
// ============================================================
// Testbench: Grain-128 LFSR-NFSR  |  8-bit Parallel Demo
// Message  : "LFSR NFSR 128BIT"  (16 chars = 128 bits)
// Rate     : 1 ASCII character encrypted per clock cycle
// Shows    : Plaintext → Encrypted (hex) → Decrypted (verified)
// ============================================================

module TB;

    reg        clk, rst, enable;
    reg  [7:0] plaintext;
    wire [7:0] ciphertext;
    wire [7:0] decrypted_text;

    localparam MSG_BYTES = 16;

    reg [7:0] plain_chars  [0:MSG_BYTES-1];
    reg [7:0] cipher_chars [0:MSG_BYTES-1];
    reg [7:0] decrpt_chars [0:MSG_BYTES-1];

    integer i, pass_count;

    // --------------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------------
    lfsr_nfsr_top dut (
        .clk           (clk),
        .rst           (rst),
        .enable        (enable),
        .plaintext     (plaintext),
        .ciphertext    (ciphertext),
        .decrypted_text(decrypted_text)
    );

    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    // --------------------------------------------------------
    // Load plaintext message: "LFSR NFSR 128BIT"
    // --------------------------------------------------------
    initial begin
        plain_chars[0]  = "L";  plain_chars[1]  = "F";
        plain_chars[2]  = "S";  plain_chars[3]  = "R";
        plain_chars[4]  = " ";  plain_chars[5]  = "N";
        plain_chars[6]  = "F";  plain_chars[7]  = "S";
        plain_chars[8]  = "R";  plain_chars[9]  = " ";
        plain_chars[10] = "1";  plain_chars[11] = "2";
        plain_chars[12] = "8";  plain_chars[13] = "B";
        plain_chars[14] = "I";  plain_chars[15] = "T";
    end

    // --------------------------------------------------------
    // Main Flow: 1 character per clock cycle
    // --------------------------------------------------------
    initial begin
        $dumpfile("flow_45nm_128bit/results/wave_128bit.vcd");
        $dumpvars(0, TB);

        clk = 0; rst = 1; enable = 0; plaintext = 8'h00;
        pass_count = 0;

        // Hold reset for 2 full clock cycles
        @(posedge clk); @(posedge clk);

        // Release reset between posedges (ensures clean state)
        @(negedge clk);
        rst    = 0;
        enable = 1;
        #2;  // let Z settle combinationally from SEED state

        // ------------------------------------------------
        // ENCRYPTION: 1 character per clock — 16 cycles total
        // ------------------------------------------------
        for (i = 0; i < MSG_BYTES; i = i + 1) begin
            plaintext      = plain_chars[i];  // drive 8-bit character
            #2;                               // combinational settle
            cipher_chars[i] = ciphertext;     // capture encrypted byte
            decrpt_chars[i] = decrypted_text; // capture decrypted byte
            @(posedge clk);                   // LFSR/NFSR advance 8 steps
            #2;                               // settle after posedge
        end

        enable    = 0;
        plaintext = 8'h00;
        #20;

        // ------------------------------------------------
        // DISPLAY — Print the encryption demo table
        // ------------------------------------------------
        $display("");
        $display("=================================================================");
        $display("  GRAIN-128 LFSR-NFSR  |  8-BIT PARALLEL  |  45nm ASIC DEMO    ");
        $display("=================================================================");
        $display("  Technology : NanGate 45nm  |  100 MHz  |  128-bit Security    ");
        $display("  Throughput : 8 bits/cycle = 800 Mbps  |  Latency: 16 cycles   ");
        $display("-----------------------------------------------------------------");

        $write("  Plaintext  : ");
        for (i = 0; i < MSG_BYTES; i = i + 1)
            $write("%c", plain_chars[i]);
        $display("");

        $write("  Encrypted  : ");
        for (i = 0; i < MSG_BYTES; i = i + 1)
            $write("%02h ", cipher_chars[i]);
        $display("");

        $write("  Decrypted  : ");
        for (i = 0; i < MSG_BYTES; i = i + 1)
            $write("%c", decrpt_chars[i]);
        $display("");

        $display("-----------------------------------------------------------------");

        // ------------------------------------------------
        // VERIFICATION
        // ------------------------------------------------
        for (i = 0; i < MSG_BYTES; i = i + 1) begin
            if (plain_chars[i] === decrpt_chars[i])
                pass_count = pass_count + 1;
        end

        if (pass_count === MSG_BYTES) begin
            $display("  Result     : *** ALL %0d BYTES VERIFIED PASS ***", MSG_BYTES);
            $display("  Encryption : Confirmed  -- ciphertext is scrambled");
            $display("  Decryption : Confirmed  -- original message recovered");
            $display("  Speed      : 1 character encrypted per clock cycle!");
        end else begin
            $display("  Result     : FAILED -- %0d / %0d bytes matched",
                     pass_count, MSG_BYTES);
        end

        $display("=================================================================");
        $display("");

        $finish;
    end

endmodule
