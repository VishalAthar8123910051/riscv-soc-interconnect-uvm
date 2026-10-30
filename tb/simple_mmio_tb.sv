
`timescale 1ns/1ps

module simple_mmio_tb;

    logic clk = 0;
    logic req = 0;
    logic we = 0;

    logic [31:0] addr = 0;
    logic [31:0] wdata = 0;
    logic [3:0] wstrb = 0;

    logic [31:0] rdata;
    logic ready;

    integer pass_count = 0;

    simple_mmio dut (
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

    task automatic write_reg(
        input logic [31:0] a,
        input logic [31:0] d,
        input logic [3:0] s
    );
        begin
            @(negedge clk);
            addr = a;
            wdata = d;
            wstrb = s;
            we = 1;
            req = 1;
            #1;

            if (ready !== 1'b1)
                $fatal(1, "FAIL: MMIO write not ready at %h", a);

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
            req = 1;
            wstrb = 4'b1111;
            #1;

            if (ready !== 1'b1)
                $fatal(1, "FAIL: MMIO read not ready at %h", a);

            @(posedge clk);
            #1;

            if (rdata !== expected)
                $fatal(1,
                    "FAIL addr=%h expected=%h actual=%h",
                    a, expected, rdata);

            $display("PASS MMIO addr=%h data=%h", a, rdata);
            pass_count = pass_count + 1;

            @(negedge clk);
            req = 0;
        end
    endtask

    initial begin
        $display("Starting MMIO tests");

        // Write and read all four registers
        write_reg(32'h0000_6000, 32'h1111_AAAA, 4'b1111);
        read_check(32'h0000_6000, 32'h1111_AAAA);

        write_reg(32'h0000_6004, 32'h2222_BBBB, 4'b1111);
        read_check(32'h0000_6004, 32'h2222_BBBB);

        write_reg(32'h0000_6008, 32'h3333_CCCC, 4'b1111);
        read_check(32'h0000_6008, 32'h3333_CCCC);

        write_reg(32'h0000_600C, 32'h4444_DDDD, 4'b1111);
        read_check(32'h0000_600C, 32'h4444_DDDD);

        // Byte lane update in REG0
        write_reg(32'h0000_6000, 32'h0000_AA00, 4'b0010);
        read_check(32'h0000_6000, 32'h1111_AAAA);

        // Invalid address check
        @(negedge clk);
        addr = 32'h0000_6010;
        req = 1;
        we = 0;
        #1;

        if (ready !== 1'b0)
            $fatal(1, "FAIL: Invalid MMIO address accepted");

        $display("PASS invalid MMIO address 00006010 rejected");
        pass_count = pass_count + 1;

        @(negedge clk);
        req = 0;

        $display("--------------------------------");
        $display("PASS: %0d checks completed", pass_count);
        $display("MMIO TESTS PASSED");
        $display("--------------------------------");

        $finish;
    end

endmodule
