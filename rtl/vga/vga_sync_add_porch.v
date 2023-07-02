`default_nettype none

// See: http://tinyvga.com/vga-timing/640x480@60Hz
module vga_sync_add_porch #(
    parameter c_COLOR_BIT_WIDTH = 3,
    parameter c_VISIBLE_COLUMNS = 640,
    parameter c_VISIBLE_ROWS = 480,
    parameter c_TOTAL_COLUMNS = 800,
    parameter c_TOTAL_ROWS = 525
)
(
    input wire i_Clk,
    input wire i_HSync,
    input wire i_VSync,
    input wire [9:0] i_ColCount,
    input wire [9:0] i_RowCount,
    input wire [c_COLOR_BIT_WIDTH - 1:0] i_RedVideo,
    input wire [c_COLOR_BIT_WIDTH - 1:0] i_GreenVideo,
    input wire [c_COLOR_BIT_WIDTH - 1:0] i_BlueVideo,
    output reg o_HSync = 1,
    output reg o_VSync = 1,
    output wire [c_COLOR_BIT_WIDTH - 1:0] o_RedVideo,
    output wire [c_COLOR_BIT_WIDTH - 1:0] o_GreenVideo,
    output wire [c_COLOR_BIT_WIDTH - 1:0] o_BlueVideo
);

localparam c_FRONT_PORCH_HORIZONTAL = 18;
localparam c_BACK_PORCH_HORIZONTAL  = 50;
localparam c_FRONT_PORCH_VERTICAL = 10;
localparam c_BACK_PORCH_VERTICAL  = 33;

always @(posedge i_Clk) begin
    
    if ((i_ColCount < (c_FRONT_PORCH_HORIZONTAL + c_VISIBLE_COLUMNS)) || (i_ColCount > (c_TOTAL_COLUMNS - c_BACK_PORCH_HORIZONTAL - 1))) begin
        o_HSync <= 1'b1;
    end
    else begin
        o_HSync <= 1'b0;
    end
    
    if ((i_RowCount < (c_FRONT_PORCH_VERTICAL + c_VISIBLE_ROWS)) || (i_RowCount > (c_TOTAL_ROWS - c_BACK_PORCH_VERTICAL - 1))) begin
        o_VSync <= 1'b1;
    end
    else begin
        o_VSync <= 1'b0;
    end

end

assign o_RedVideo = i_RedVideo;
assign o_GreenVideo = i_GreenVideo;
assign o_BlueVideo = i_BlueVideo;

endmodule
