
`timescale 1ns/1ps

module simple_sram_tb;

logic clk = 0;
    logic req = 0;
    logic we = 0;
    logic [31:0] addr = 0;
    logic [31:0] wdata = 0;
    logic [3:0] wstrb = 0;
    logic [31:0] rdata;
    logic ready;

    integer pass_count = 0;

simple_sram dut (
        .clk(clk),
        .req(req),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .rdata(rdata),
        .ready(ready)
    );

    always #5 clk = ~clk;

task automatic write_word(
        input logic [31:0] a,
        input logic [31:0] d,
        input logic [3:0]  strobe
    );
        begin
            @(negedge clk);
            addr  = a;
            wdata = d;
            wstrb = strobe;
            we    = 1;
            req   = 1;

#1;
            if (!ready)
                $fatal(1, "Write address invalid: %h", a);

@(posedge clk);
            #1;

@(negedge clk);
            req = 0;
            we  = 0;
            wstrb = 0;
        end
    endtask

task automatic read_check(
        input logic [31:0] a,
        input logic [31:0] expected
    );
        begin
            @(negedge clk);
            addr = a;
            we   = 0;
            req  = 1;

#1;
            if (!ready)
                $fatal(1, "Read address invalid: %h", a);

@(posedge clk);
            #1;

if (rdata !== expected)
                $fatal(1,
                    "FAIL addr=%h expected=%h got=%h",
                    a, expected, rdata);

$display("PASS addr=%h data=%h", a, rdata);
            pass_count = pass_count + 1;

@(negedge clk);
            req = 0;
        end
    endtask

initial begin
        $display("Starting SRAM read/write tests");

// Full-word write/read
        write_word(32'h0000_0000, 32'h1122_3344, 4'b1111);
        read_check (32'h0000_0000, 32'h1122_3344);

// Another independent word
        write_word(32'h0000_0004, 32'hDEAD_BEEF, 4'b1111);
        read_check (32'h0000_0004, 32'hDEAD_BEEF);

// Byte lane 1 only: CC -> AA
        write_word(32'h0000_0000, 32'h0000_AA00, 4'b0010);
        read_check (32'h0000_0000, 32'h1122_AA44);

// Last aligned word in 16 KB SRAM
        write_word(32'h0000_3FFC, 32'hCAFE_BABE, 4'b1111);
        read_check (32'h0000_3FFC, 32'hCAFE_BABE);

$display("--------------------------------");
        $display("PASS: %0d read checks", pass_count);
        $display("ALL SRAM TESTS PASSED");
        $display("--------------------------------");

$finish;
    end

endmodule
