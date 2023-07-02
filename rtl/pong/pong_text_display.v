`default_nettype none

module pong_text_display #(
    parameter c_PONG_VISIBLE_COLUMNS = 40,
    parameter c_PONG_VISIBLE_ROWS = 30,
    parameter c_PONG_TEXT_X_POS = 15,
    parameter c_PONG_TEXT_Y_POS = 0,
    parameter c_MAX_STR_LEN = 15
)
(
    input wire i_Clk,
    input wire [5:0] i_ColCount_Div,
    input wire [5:0] i_RowCount_Div,
    input wire [c_MAX_STR_LEN*8:0] i_DisplayStr,
    output wire o_DrawLetter
);

    reg [4:0] r_font_pixel_col_idx = 0;
    reg [4:0] r_font_pixel_row_idx = 0;
    reg [4:0] r_font_pixel_idx = 15;

    reg [4:0] r_font_addr = 0;
    wire [15:0] w_font_data;

    reg [4:0] r_letter_idx = 0;

    block_ram #(
        .ADDR_WIDTH(5),
        .DATA_WIDTH(16), 
        .MEM_INIT_FILE("pong/text_fonts.mem")
    ) letter_block_ram_inst
    (
        .i_clk(i_Clk),
        .i_write_en(1'b0),
        .i_addr(r_font_addr),
        .i_din(),
        .o_dout(w_font_data)
    );

    assign o_DrawLetter = w_font_data[r_font_pixel_idx];

    always @(posedge i_Clk) begin

        r_font_addr <= i_ScoreCount;
       
        r_font_pixel_idx <= r_font_pixel_row_idx + r_font_pixel_col_idx;

        // In order to correctly print the pixels of the symbol, we need to update the
        // pixel index in a interval 0, 1, 2 for the first row (first 16 columns of the real column counter)
        // and then in the interval 3, 4, 5 for the next row, etc..

        if ((i_ColCount_Div >= c_SCORE_BOARD_X_POS) && (i_ColCount_Div < (c_SCORE_BOARD_X_POS + 3)) && (i_RowCount_Div >= c_SCORE_BOARD_Y_POS) && (i_RowCount_Div < (c_SCORE_BOARD_Y_POS + 5))) begin

            //o_DrawLetter <= w_font_data[r_font_pixel_idx];

            if(i_ColCount_Div == c_SCORE_BOARD_X_POS) begin
               r_font_pixel_col_idx <= 0; 
            end
            else if(i_ColCount_Div == c_SCORE_BOARD_X_POS + 1) begin
               r_font_pixel_col_idx <= 1;
            end
            else if(i_ColCount_Div == c_SCORE_BOARD_X_POS + 2) begin
               r_font_pixel_col_idx <= 2;
            end

            if(i_RowCount_Div == c_SCORE_BOARD_Y_POS) begin
                r_font_pixel_row_idx <= 0;
            end
            else if(i_RowCount_Div == c_SCORE_BOARD_Y_POS + 1) begin
                r_font_pixel_row_idx <= 3;
            end
            else if(i_RowCount_Div == c_SCORE_BOARD_Y_POS + 2) begin
                r_font_pixel_row_idx <= 6;
            end
            else if(i_RowCount_Div == c_SCORE_BOARD_Y_POS + 3) begin
                r_font_pixel_row_idx <= 9;
            end
            else if(i_RowCount_Div == c_SCORE_BOARD_Y_POS + 4) begin
                r_font_pixel_row_idx <= 12;
            end

        end
        else begin
            r_font_pixel_col_idx <= 10;
            r_font_pixel_row_idx <= 5;
            //o_DrawLetter <= 1'b0;
        end

    end


endmodule
