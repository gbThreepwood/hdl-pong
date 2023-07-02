`default_nettype none

module vga_sync_pulses #(
    parameter c_VISIBLE_COLUMNS = 640,
    parameter c_VISIBLE_ROWS = 480, 
    parameter c_TOTAL_COLUMNS = 800,
    parameter c_TOTAL_ROWS = 525 
)
(
    input i_Clk,
    output wire o_HSync,
    output wire o_VSync,
    output reg [9:0] o_ColCount = 0,
    output reg [9:0] o_RowCount = 0
);


    always @(posedge i_Clk) begin
    
        if(o_ColCount == c_TOTAL_COLUMNS - 1) begin
            o_ColCount <= 0;

            if(o_RowCount == c_TOTAL_ROWS - 1) begin
                o_RowCount <= 0;
            end
            else begin
                o_RowCount <= o_RowCount + 1;
            end

        end
        else begin
            o_ColCount <= o_ColCount + 1;
        end

    end
    
    //always @(*) begin
    //    
    //    if(o_ColCount < c_VISIBLE_COLUMNS)
    //        o_HSync = 1'b1;
    //    else
    //        o_HSync = 1'b0;

    //    if(o_RowCount < c_VISIBLE_ROWS)
    //        o_VSync = 1'b1;
    //    else
    //        o_VSync = 1'b0;

    //end

    assign o_HSync = o_ColCount < c_VISIBLE_COLUMNS ? 1'b1 : 1'b0;
    assign o_VSync = o_RowCount < c_VISIBLE_ROWS ? 1'b1 : 1'b0;

endmodule