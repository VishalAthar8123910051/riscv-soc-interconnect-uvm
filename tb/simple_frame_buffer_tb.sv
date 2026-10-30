
`timescale 1ns/1ps

module simple_frame_buffer_tb;

    logic clk = 0;
    logic req = 0;
    logic we = 0;
    logic [31:0] addr = 0;
    logic [31:0] wdata = 0;
    logic [3:0] wstrb = 4'b1111;

    logic [31:0] rdata;
    logic ready;

    integer pass_count = 0;

    simple_frame_buffer dut (
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
        input logic [3:0] s
    );
        begin
            @(negedge clk);
            req = 1;
            we = 1;
            addr = a;
            wdata = d;
            wstrb = s;

            @(posedge clk);
            #1;

            if (!ready)
                $fatal(1, "FAIL: Write not ready at %h", a);

            @(negedge clk);
            req = 0;
            we = 0;
        end
    endtask

    task automatic check_read(
        input logic [31:0] a,
        input logic [31:0] expected
    );
        begin
            @(negedge clk);
            req = 1;
            we = 0;
            addr = a;

            @(posedge clk);
            #1;

            if (!ready)
                $fatal(1, "FAIL: Read not ready at %h", a);

            if (rdata !== expected)
                $fatal(1,
                    "FAIL addr=%h expected=%h actual=%h",
                    a, expected, rdata);

            $display("PASS addr=%h data=%h", a, rdata);
            pass_count = pass_count + 1;

            @(negedge clk);
            req = 0;
        end
    endtask

    initial begin
        $display("Starting Frame Buffer tests");

        // First word write/read
        write_word(32'h0000_4000, 32'h1234_ABCD, 4'b1111);
        check_read(32'h0000_4000, 32'h1234_ABCD);

        // Byte lane 1 update
        write_word(32'h0000_4000, 32'h0000_AA00, 4'b0010);
        check_read(32'h0000_4000, 32'h1234_AACD);

        // Last aligned word
        write_word(32'h0000_5FFC, 32'hCAFE_BABE, 4'b1111);
        check_read(32'h0000_5FFC, 32'hCAFE_BABE);

        // Invalid address check
        @(negedge clk);
        req = 1;
        we = 0;
        addr = 32'h0000_6000;

        #1;
        if (ready !== 1'b0)
            $fatal(1, "FAIL: Invalid address was accepted");

        $display("PASS invalid address 00006000 rejected");
        pass_count = pass_count + 1;

        @(negedge clk);
        req = 0;

        $display("--------------------------------");
        $display("PASS: %0d checks completed", pass_count);
        $display("FRAME BUFFER TESTS PASSED");
        $display("--------------------------------");

        $finish;
    end

endmodule
