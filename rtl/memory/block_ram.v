`default_nettype none

module block_ram #(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 8,
    parameter MEM_INIT_FILE = ""
)
(
    input wire i_clk,
    input wire i_write_en,
    input wire [ADDR_WIDTH - 1:0] i_addr,
    input wire [DATA_WIDTH - 1:0] i_din,
    output reg [DATA_WIDTH - 1:0] o_dout = 0
);

    // This should infer a block RAM:
    reg [DATA_WIDTH-1:0] mem [(1 << ADDR_WIDTH) - 1:0];

    initial begin
        if(MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, mem);
        end
    end


    always @(posedge i_clk) begin
        if(i_write_en) begin
            mem[(i_addr)] <= i_din;
        end

        o_dout <= mem[i_addr];
    end

endmodule
