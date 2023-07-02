`default_nettype none

module pong_game_top(
    input  i_Clk,
    input  i_UART_RX,
    output o_UART_TX, 

    input i_Switch_1,
    input i_Switch_2,
    input i_Switch_3,
    input i_Switch_4,

    output o_LED_1,
    output o_LED_2,
    output o_LED_3,
    output o_LED_4,

    // Segment 1
    output o_Segment1_A,
    output o_Segment1_B,
    output o_Segment1_C,
    output o_Segment1_D,
    output o_Segment1_E,
    output o_Segment1_F,
    output o_Segment1_G,

    // Segment 2
    output o_Segment2_A,
    output o_Segment2_B,
    output o_Segment2_C,
    output o_Segment2_D,
    output o_Segment2_E,
    output o_Segment2_F,
    output o_Segment2_G,
    
    // VGA
    output o_VGA_HSync,
    output o_VGA_VSync,
    output o_VGA_Red_0,
    output o_VGA_Red_1,
    output o_VGA_Red_2,
    output o_VGA_Grn_0,
    output o_VGA_Grn_1,
    output o_VGA_Grn_2,
    output o_VGA_Blu_0,
    output o_VGA_Blu_1,
    output o_VGA_Blu_2,

    // PMOD
    inout io_PMOD_1,
    inout io_PMOD_2,
    inout io_PMOD_3,
    inout io_PMOD_4,
    inout io_PMOD_7,
    inout io_PMOD_8,
    inout io_PMOD_9,
    inout io_PMOD_10
);

    wire [6:0] w_o_Segment1 = { o_Segment1_G, o_Segment1_F, o_Segment1_E, o_Segment1_D, o_Segment1_C, o_Segment1_B, o_Segment1_A };
    wire [6:0] w_o_Segment2 = { o_Segment2_G, o_Segment2_F, o_Segment2_E, o_Segment2_D, o_Segment2_C, o_Segment2_B, o_Segment2_A };

    wire [2:0] w_o_VGA_Red = { o_VGA_Red_2, o_VGA_Red_1, o_VGA_Red_0 };
    wire [2:0] w_o_VGA_Green = { o_VGA_Grn_2, o_VGA_Grn_1, o_VGA_Grn_0 };
    wire [2:0] w_o_VGA_Blue = { o_VGA_Blu_2, o_VGA_Blu_1, o_VGA_Blu_0 };

    //wire [7:0] w_ram_data;

    //block_ram #(
    //    .ADDR_WIDTH(4),
    //    .DATA_WIDTH(9), // 0x1ff is the max value
    //    .MEM_INIT_FILE("memory_init_test.mem")
    //) block_ram_1_inst
    //(
    //    .i_clk(i_Clk),
    //    .i_write_en(1'b0),
    //    .i_addr(4'd10),
    //    .i_din(),
    //    .o_dout(w_ram_data)
    //);

    wire [3:0] w_P1_ScoreCount;
    wire [3:0] w_P2_ScoreCount;

    wire [6:0] w_Segment1;
    wire [6:0] w_Segment2;

    bin_to_7_seg seg1_inst (
        .i_bin_num(w_P1_ScoreCount),
        .i_enable(1'b1),
        .i_invert(1'b1),
        .o_out_seg(w_o_Segment1)
    );

    bin_to_7_seg seg2_inst (
        .i_bin_num(w_P2_ScoreCount),
        .i_enable(1'b1),
        .i_invert(1'b1),
        .o_out_seg(w_o_Segment2)
    );

    localparam c_VGA_COLOR_BIT_WIDTH = 3;
    localparam c_VISIBLE_COLUMNS = 640;
    localparam c_VISIBLE_ROWS = 480;
    localparam c_TOTAL_COLUMNS = 800;
    localparam c_TOTAL_ROWS = 525;

    wire w_HSync;
    wire w_VSync;
    wire [9:0] w_ColCount;
    wire [9:0] w_RowCount;

    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_RedVideo_TestPattern;
    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_GreenVideo_TestPattern;
    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_BlueVideo_TestPattern;

    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_RedVideo_Pong;
    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_GreenVideo_Pong;
    wire [c_VGA_COLOR_BIT_WIDTH - 1:0] w_BlueVideo_Pong;

    wire w_Switch_1_debounced;
    wire w_Switch_2_debounced;
    wire w_Switch_3_debounced;
    wire w_Switch_4_debounced;

    reg r_Switch_1_prev = 0;
    reg r_Switch_2_prev = 0;
    reg r_Switch_3_prev = 0;
    reg r_Switch_4_prev = 0;

    reg [3:0] r_PatternSelect = 0;

    vga_sync_pulses #(
        .c_VISIBLE_COLUMNS(c_VISIBLE_COLUMNS),
        .c_VISIBLE_ROWS(c_VISIBLE_ROWS), 
        .c_TOTAL_COLUMNS(c_TOTAL_COLUMNS),
        .c_TOTAL_ROWS(c_TOTAL_ROWS) 
    ) vga_sync_pulses_inst
    (
        .i_Clk(i_Clk),
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
        .i_Clk(i_Clk),
        .i_PatternSelect(r_PatternSelect),
        .i_HSync(w_HSync),
        .i_VSync(w_VSync),
        .i_ColCount(w_ColCount),
        .i_RowCount(w_RowCount),
        .o_HSync(),
        .o_VSync(),
        .o_VideoRed(w_RedVideo_TestPattern),
        .o_VideoGreen(w_GreenVideo_TestPattern),
        .o_VideoBlue(w_BlueVideo_TestPattern)
    );

    pong_top #(
        .c_COLOR_BIT_WIDTH(3),
        .c_VISIBLE_COLUMNS(640),
        .c_VISIBLE_ROWS(480),
        .c_TOTAL_COLUMNS(800),
        .c_TOTAL_ROWS(525)
    ) pong_top_inst (
        .i_Clk(i_Clk),
        .i_HSync(w_HSync),
        .i_VSync(w_VSync),
        .i_ColCount(w_ColCount),
        .i_RowCount(w_RowCount),
        .i_StartGame(w_Switch_1_debounced),
        .i_Paddle_P1_Up(w_Switch_1_debounced),
        .i_Paddle_P1_Down(w_Switch_2_debounced),
        .i_Paddle_P2_Up(w_Switch_3_debounced),
        .i_Paddle_P2_Down(w_Switch_4_debounced),
        .o_P1_ScoreCount(w_P1_ScoreCount), 
        .o_P2_ScoreCount(w_P2_ScoreCount),
        .o_HSync(),
        .o_VSync(),
        .o_VideoRed(w_RedVideo_Pong),
        .o_VideoGreen(w_GreenVideo_Pong),
        .o_VideoBlue(w_BlueVideo_Pong)
    );

    vga_sync_add_porch #(
        .c_COLOR_BIT_WIDTH(c_VGA_COLOR_BIT_WIDTH),
        .c_VISIBLE_COLUMNS(c_VISIBLE_COLUMNS),
        .c_VISIBLE_ROWS(c_VISIBLE_ROWS),
        .c_TOTAL_COLUMNS(c_TOTAL_COLUMNS),
        .c_TOTAL_ROWS(c_TOTAL_ROWS)
    ) vga_sync_add_porch_inst (
        .i_Clk(i_Clk),
        .i_HSync(w_HSync),
        .i_VSync(w_VSync),
        .i_ColCount(w_ColCount),
        .i_RowCount(w_RowCount),
        .i_RedVideo(w_RedVideo_TestPattern),
        .i_GreenVideo(w_GreenVideo_TestPattern),
        .i_BlueVideo(w_BlueVideo_TestPattern),
        .o_HSync(o_VGA_HSync),
        .o_VSync(o_VGA_VSync),
        .o_RedVideo(),
        .o_GreenVideo(),
        .o_BlueVideo()
    );

    debounce_switch debounce_switch_1_inst (
        .i_Clk(i_Clk),
        .i_Switch(i_Switch_1),
        .o_Switch(w_Switch_1_debounced)
    );

    debounce_switch debounce_switch_2_inst (
        .i_Clk(i_Clk),
        .i_Switch(i_Switch_2),
        .o_Switch(w_Switch_2_debounced)
    );

    debounce_switch debounce_switch_3_inst (
        .i_Clk(i_Clk),
        .i_Switch(i_Switch_3),
        .o_Switch(w_Switch_3_debounced)
    );

    debounce_switch debounce_switch_4_inst (
        .i_Clk(i_Clk),
        .i_Switch(i_Switch_4),
        .o_Switch(w_Switch_4_debounced)
    );


    reg [2:0] r_VideoSourceSelect = 1;


    //always @(posedge i_Clk) begin
    //   
    //    r_Switch_2_prev <= w_Switch_2_debounced;

    //    if(w_Switch_2_debounced == 1'b1 && r_Switch_2_prev == 1'b0) begin // Detect rising edge (switch press)
    //        if(r_VideoSourceSelect < 1) begin
    //            r_VideoSourceSelect <= r_VideoSourceSelect + 1;
    //        end
    //        else begin
    //            r_VideoSourceSelect <= 0;
    //        end
    //    end

    //end

    //always @(*) begin
    //    case(r_VideoSourceSelect)
    //        3'b000 : begin
    //            w_o_VGA_Red = w_RedVideo_TestPattern;
    //            w_o_VGA_Green = w_GreenVideo_TestPattern;
    //            w_o_VGA_Blue = w_BlueVideo_TestPattern;
    //        end
    //        3'b001 : begin
    //            w_o_VGA_Red = w_RedVideo_TestPattern;
    //            w_o_VGA_Green = w_GreenVideo_TestPattern;
    //            w_o_VGA_Blue = w_BlueVideo_TestPattern;
    //        end
    //        default: begin
    //            w_o_VGA_Red = w_RedVideo_TestPattern;
    //            w_o_VGA_Green = w_GreenVideo_TestPattern;
    //            w_o_VGA_Blue = w_BlueVideo_TestPattern;               
    //        end
    //    endcase
    //end

    assign w_o_VGA_Red = r_VideoSourceSelect[0] ? w_RedVideo_Pong : w_RedVideo_TestPattern;
    assign w_o_VGA_Green = r_VideoSourceSelect[0] ? w_GreenVideo_Pong : w_GreenVideo_TestPattern;
    assign w_o_VGA_Blue = r_VideoSourceSelect[0] ? w_BlueVideo_Pong : w_BlueVideo_TestPattern;

    always @(posedge i_Clk) begin
        r_Switch_1_prev <= w_Switch_1_debounced;

        if(w_Switch_1_debounced == 1'b0 && r_Switch_1_prev == 1'b1) begin // Check for switch release
            
            if(r_PatternSelect < 7) begin
                r_PatternSelect = r_PatternSelect + 1;
            end
            else begin
                r_PatternSelect <= 0;
            end
            
        end
    end

    //assign o_VGA_Red_0 = w_RedVideo[0];
    //assign o_VGA_Red_1 = w_RedVideo[1];
    //assign o_VGA_Red_2 = w_RedVideo[2];

    //assign o_VGA_Grn_0 = w_GreenVideo[0];
    //assign o_VGA_Grn_1 = w_GreenVideo[1];
    //assign o_VGA_Grn_2 = w_GreenVideo[2];

    //assign o_VGA_Blu_0 = w_BlueVideo[0];
    //assign o_VGA_Blu_1 = w_BlueVideo[1];
    //assign o_VGA_Blu_2 = w_BlueVideo[2];

    assign o_LED_1 = r_PatternSelect[0];
    assign o_LED_2 = r_PatternSelect[1];
    assign o_LED_3 = r_PatternSelect[2];
    assign o_LED_4 = r_PatternSelect[3];

endmodule
