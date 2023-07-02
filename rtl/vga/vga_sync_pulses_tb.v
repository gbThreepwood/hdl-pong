`default_nettype none
`timescale 1ns/10ps

module vga_sync_pulses_tb();

    localparam c_CLOCK_PERIOD_NS = 40;

    localparam c_VGA_COLOR_BIT_WIDTH = 3;
    localparam c_VISIBLE_COLUMNS = 640;
    localparam c_VISIBLE_ROWS = 480;
    localparam c_TOTAL_COLUMNS = 800;
    localparam c_TOTAL_ROWS = 525;


    reg r_Clk = 0;
    wire w_HSync;
    wire w_VSync;
    wire [9:0] w_ColCount;
    wire [9:0] w_RowCount;

    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_RedVideo;
    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_GreenVideo;
    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_BlueVideo;

    vga_sync_pulses #(
        .c_VISIBLE_COLUMNS(640),
        .c_VISIBLE_ROWS(480), 
        .c_TOTAL_COLUMNS(800),
        .c_TOTAL_ROWS(525) 
    ) vga_sync_pulses_inst (
        .i_Clk(r_Clk),
        .o_HSync(w_HSync),
        .o_VSync(w_VSync),
        .o_ColCount(w_ColCount),
        .o_RowCount(w_RowCount)
    );

    vga_test_pattern_generator #(
        .c_COLOR_BIT_WIDTH(c_VGA_COLOR_BIT_WIDTH),
        .c_VISIBLE_COLUMNS(c_VISIBLE_COLUMNS),
        .c_VISIBLE_ROWS(c_VISIBLE_ROWS), 
        .c_TOTAL_COLUMNS(c_TOTAL_COLUMNS),
        .c_TOTAL_ROWS(c_TOTAL_ROWS) 
    ) vga_test_pattern_generator_inst (
        .i_Clk(r_Clk),
        .i_PatternSelect(4'h5),
        .i_HSync(w_HSync),
        .i_VSync(w_VSync),
        .i_ColCount(w_ColCount),
        .i_RowCount(w_RowCount),
        .o_HSync(),
        .o_VSync(),
        .o_VideoRed(w_RedVideo),
        .o_VideoGreen(w_GreenVideo),
        .o_VideoBlue(w_BlueVideo)
    );


    pong_top #(
        .c_COLOR_BIT_WIDTH(3),
        .c_VISIBLE_COLUMNS(640),
        .c_VISIBLE_ROWS(480),
        .c_TOTAL_COLUMNS(800),
        .c_TOTAL_ROWS(525)
    ) pong_top_inst (
        .i_Clk(r_Clk),
        .i_HSync(w_HSync),
        .i_VSync(w_VSync),
        .i_ColCount(w_ColCount),
        .i_RowCount(w_RowCount),
        .i_StartGame(),
        .i_Paddle_P1_Up(),
        .i_Paddle_P1_Down(),
        .i_Paddle_P2_Up(),
        .i_Paddle_P2_Down(),
        .o_P1_ScoreCount(), 
        .o_P2_ScoreCount(),
        .o_HSync(),
        .o_VSync(),
        .o_VideoRed(),
        .o_VideoGreen(),
        .o_VideoBlue()
    );



    vga_sync_add_porch #(
        .c_COLOR_BIT_WIDTH(c_VGA_COLOR_BIT_WIDTH),
        .c_VISIBLE_COLUMNS(c_VISIBLE_COLUMNS),
        .c_VISIBLE_ROWS(c_VISIBLE_ROWS),
        .c_TOTAL_COLUMNS(c_TOTAL_COLUMNS),
        .c_TOTAL_ROWS(c_TOTAL_ROWS)
    ) vga_sync_add_porch_inst (
        .i_Clk(r_Clk),
        .i_HSync(w_HSync),
        .i_VSync(w_VSync),
        .i_ColCount(w_ColCount),
        .i_RowCount(w_RowCount),
        .i_RedVideo(w_RedVideo),
        .i_GreenVideo(w_GreenVideo),
        .i_BlueVideo(w_BlueVideo),
        .o_HSync(),
        .o_VSync(),
        .o_RedVideo(),
        .o_GreenVideo(),
        .o_BlueVideo()
    );

    always
        #(c_CLOCK_PERIOD_NS/2) r_Clk <= ~r_Clk;


    initial begin
        @(posedge r_Clk);
        @(posedge r_Clk);

        //if(r_ColCount == 799)
        
        #16800000

        $display("Test finished.");
        $finish;
    end
        

    initial 
        begin
          $dumpfile("dump.vcd");
          $dumpvars(0);
        end

endmodule
