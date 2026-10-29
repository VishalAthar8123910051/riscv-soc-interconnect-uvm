
module address_decoder (
    input  logic [31:0] addr,
    output logic        sram_sel,
    output logic        fb_sel,
    output logic        mmio_sel
);

    always_comb begin
        sram_sel = 1'b0;
        fb_sel   = 1'b0;
        mmio_sel = 1'b0;

        if (addr <= 32'h0000_3FFF)
            sram_sel = 1'b1;
        else if (addr <= 32'h0000_5FFF)
            fb_sel = 1'b1;
        else
            mmio_sel = 1'b1;
    end

endmodule
