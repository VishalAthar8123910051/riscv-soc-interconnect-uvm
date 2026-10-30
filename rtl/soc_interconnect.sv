
`timescale 1ns/1ps

module soc_interconnect (
    input  logic        clk,
    input  logic        req,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,

    output logic [31:0] rdata,
    output logic        ready,

    output logic        sram_sel,
    output logic        fb_sel,
    output logic        mmio_sel
);

    logic [31:0] sram_rdata;
    logic [31:0] fb_rdata;

    logic sram_ready;
    logic fb_ready;

    logic sram_req;
    logic fb_req;

    // Address decoder
    address_decoder u_decoder (
        .addr(addr),
        .sram_sel(sram_sel),
        .fb_sel(fb_sel),
        .mmio_sel(mmio_sel)
    );

    // Route requests
    assign sram_req = req && sram_sel;
    assign fb_req   = req && fb_sel;

    // SRAM instance
    simple_sram u_sram (
        .clk(clk),
        .req(sram_req),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .rdata(sram_rdata),
        .ready(sram_ready)
    );

    // Frame Buffer instance
    simple_frame_buffer u_fb (
        .clk(clk),
        .req(fb_req),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .rdata(fb_rdata),
        .ready(fb_ready)
    );

    // Read-data and ready response mux
    always_comb begin
        rdata = 32'b0;
        ready = 1'b0;

        if (sram_sel) begin
            rdata = sram_rdata;
            ready = sram_ready;
        end
        else if (fb_sel) begin
            rdata = fb_rdata;
            ready = fb_ready;
        end
    end

endmodule

