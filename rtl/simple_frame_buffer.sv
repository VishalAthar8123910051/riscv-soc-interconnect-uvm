
`timescale 1ns/1ps

module simple_frame_buffer (
    input  logic        clk,
    input  logic        req,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    output logic [31:0] rdata,
    output logic        ready
);

    // 8 KB = 2048 words x 32 bits
    logic [31:0] mem [0:2047];

    wire addr_valid =
        (addr >= 32'h0000_4000) &&
        (addr <= 32'h0000_5FFF) &&
        (addr[1:0] == 2'b00);

    assign ready = req && addr_valid;

    always_ff @(posedge clk) begin
        if (req && addr_valid) begin
            if (we) begin
                if (wstrb[0])
                    mem[addr[12:2]][7:0] <= wdata[7:0];
                if (wstrb[1])
                    mem[addr[12:2]][15:8] <= wdata[15:8];
                if (wstrb[2])
                    mem[addr[12:2]][23:16] <= wdata[23:16];
                if (wstrb[3])
                    mem[addr[12:2]][31:24] <= wdata[31:24];
            end
            else begin
                rdata <= mem[addr[12:2]];
            end
        end
    end

endmodule
