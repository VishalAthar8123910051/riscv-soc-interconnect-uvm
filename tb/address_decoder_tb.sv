
`timescale 1ns/1ps

module address_decoder_tb;

    logic [31:0] addr;
    logic sram_sel;
    logic fb_sel;
    logic mmio_sel;

    integer pass_count = 0;

    address_decoder dut (
        .addr(addr),
        .sram_sel(sram_sel),
        .fb_sel(fb_sel),
        .mmio_sel(mmio_sel)
    );

    task automatic check_address(
        input logic [31:0] test_addr,
        input logic exp_sram,
        input logic exp_fb,
        input logic exp_mmio
    );
        begin
            addr = test_addr;
            #1;

            if ({sram_sel, fb_sel, mmio_sel} !==
                {exp_sram, exp_fb, exp_mmio}) begin
                $error("FAIL addr=%h: SRAM=%b FB=%b MMIO=%b",
                       addr, sram_sel, fb_sel, mmio_sel);
                $fatal(1, "Address decoder test failed");
            end

            $display("PASS addr=%h SRAM=%b FB=%b MMIO=%b",
                     addr, sram_sel, fb_sel, mmio_sel);
            pass_count = pass_count + 1;
        end
    endtask

    initial begin
        $display("Starting address decoder tests");

        check_address(32'h0000_0000, 1, 0, 0);
        check_address(32'h0000_3FFC, 1, 0, 0);
        check_address(32'h0000_3FFF, 1, 0, 0);
        check_address(32'h0000_4000, 0, 1, 0);
        check_address(32'h0000_5FFC, 0, 1, 0);
        check_address(32'h0000_5FFF, 0, 1, 0);
        check_address(32'h0000_6000, 0, 0, 1);
        check_address(32'h0000_6004, 0, 0, 1);
        check_address(32'h0000_7000, 0, 0, 1);

        $display("--------------------------------");
        $display("PASS: %0d tests completed", pass_count);
        $display("ALL ADDRESS DECODER TESTS PASSED");
        $display("--------------------------------");

        $finish;
    end

endmodule
