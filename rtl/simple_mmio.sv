
`timescale 1ns/1ps

module simple_mmio (
    input  logic        clk,
    input  logic        req,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,

    output logic [31:0] rdata,
    output logic        ready
);

    logic [31:0] regs [0:3];

    wire addr_valid =
        (addr >= 32'h0000_6000) &&
        (addr <= 32'h0000_600C) &&
        (addr[1:0] == 2'b00);

    assign ready = req && addr_valid;

    always_ff @(posedge clk) begin
        if (req && addr_valid) begin
            if (we) begin
                if (wstrb[0])
                    regs[addr[3:2]][7:0] <= wdata[7:0];

                if (wstrb[1])
                    regs[addr[3:2]][15:8] <= wdata[15:8];

                if (wstrb[2])
                    regs[addr[3:2]][23:16] <= wdata[23:16];

                if (wstrb[3])
                    regs[addr[3:2]][31:24] <= wdata[31:24];
            end
            else begin
                rdata <= regs[addr[3:2]];
            end
        end
    end

endmodule
