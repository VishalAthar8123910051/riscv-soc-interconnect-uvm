`timescale 1ns/1ps

module soc_interconnect_tb;

logic clk = 0;
    logic req = 0;
    logic we = 0;
    logic [31:0] addr = 0;
    logic [31:0] wdata = 0;
    logic [3:0] wstrb = 0;

logic [31:0] rdata;
    logic ready;
    logic sram_sel, fb_sel, mmio_sel;

    integer pass_count = 0;

soc_interconnect dut (
        .clk(clk),
        .req(req),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .rdata(rdata),
        .ready(ready),
        .sram_sel(sram_sel),
        .fb_sel(fb_sel),
        .mmio_sel(mmio_sel)
    );

    always #5 clk = ~clk;

task automatic write_word(
        input logic [31:0] a,
        input logic [31:0] d
    );
        begin
            @(negedge clk);
            addr = a;
            wdata = d;
            wstrb = 4'b1111;
            we = 1;
            req = 1;
            #1;

if (!sram_sel || !ready)
                $fatal(1, "SRAM write not selected at %h", a);

@(posedge clk);
            #1;
            @(negedge clk);
            req = 0;
            we = 0;
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
            we = 0;
            wstrb = 0;
            req = 1;
            #1;

if (!sram_sel || !ready)
                $fatal(1, "SRAM read not selected at %h", a);

@(posedge clk);
            #1;

if (rdata !== expected)
                $fatal(1,
                    "Read mismatch at %h: expected %h got %h",
                    a, expected, rdata);

$display("PASS SRAM addr=%h data=%h", a, rdata);
            pass_count = pass_count + 1;

@(negedge clk);
            req = 0;
        end
    endtask

task automatic check_other_target(
        input logic [31:0] a,
        input logic expected_fb,
        input logic expected_mmio
    );
        begin
            @(negedge clk);
            addr = a;
            req = 1;
            we = 0;
            #1;

if (sram_sel !== 1'b0 ||
                fb_sel !== expected_fb ||
                mmio_sel !== expected_mmio ||
                ready !== 1'b0) begin
                $fatal(1, "Target decode failed at %h", a);
            end

$display("PASS target decode addr=%h FB=%b MMIO=%b",
                     a, fb_sel, mmio_sel);
            pass_count = pass_count + 1;

@(negedge clk);
            req = 0;
        end
    endtask

initial begin
        $display("Starting SoC interconnect tests");

write_word(32'h0000_0000, 32'h1234_ABCD);
        read_check (32'h0000_0000, 32'h1234_ABCD);

write_word(32'h0000_3FFC, 32'hCAFE_BABE);
        read_check (32'h0000_3FFC, 32'hCAFE_BABE);

check_other_target(32'h0000_4000, 1'b1, 1'b0);
        check_other_target(32'h0000_6000, 1'b0, 1'b1);

$display("--------------------------------");
        $display("PASS: %0d checks completed", pass_count);
        $display("INTERCONNECT TESTS PASSED");
        $display("--------------------------------");
        $finish;
    end

endmodule
