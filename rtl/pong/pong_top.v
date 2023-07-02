`default_nettype none

module pong_top #(
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
    input wire i_StartGame,
    input wire i_Paddle_P1_Up,
    input wire i_Paddle_P1_Down,
    input wire i_Paddle_P2_Up,
    input wire i_Paddle_P2_Down,
    output wire [3:0] o_P1_ScoreCount, 
    output wire [3:0] o_P2_ScoreCount, 
    output reg o_HSync,
    output reg o_VSync,
    output wire [c_COLOR_BIT_WIDTH - 1:0] o_VideoRed,
    output wire [c_COLOR_BIT_WIDTH - 1:0] o_VideoGreen,
    output wire [c_COLOR_BIT_WIDTH - 1:0] o_VideoBlue
);

    localparam c_PADDLE_HEIGHT = 6;
    localparam c_GAME_WINDOW_WIDTH = 40;
    localparam c_SCORE_LIMIT = 9;

    localparam c_PONG_NET_POSITION = 19;

    parameter STATE_IDLE      = 3'b000;
    parameter STATE_RUNNING   = 3'b001;
    parameter STATE_P1_SCORES = 3'b010;
    parameter STATE_P2_SCORES = 3'b011;
    parameter STATE_CLEANUP   = 3'b100;

    reg [2:0] r_StateMachine_State = STATE_IDLE;

    reg [3:0] r_P1_ScoreCount = 0;
    reg [3:0] r_P2_ScoreCount = 0;

    wire [5:0] w_ColCount_Div;
    wire [5:0] w_RowCount_Div;

    assign w_ColCount_Div = i_ColCount[9:4]; // Drop the 4 least significant bits, i.e. divide by 16.
    assign w_RowCount_Div = i_RowCount[9:4];

    wire w_GameRunning;

    wire [5:0] w_Paddle1_Y_Pos;
    wire [5:0] w_Paddle2_Y_Pos;

    wire [5:0] w_Ball_X_Pos;
    wire [5:0] w_Ball_Y_Pos;

    wire w_DrawPaddle1;
    wire w_DrawPaddle2;
    wire w_DrawBall;
    wire w_DrawScore_P1;
    wire w_DrawScore_P2;
    reg r_DrawNet;

    wire w_DrawCurrentPixel;

    pong_paddle_control #(
        .c_PADDLE_X_POSITION(0),
        .c_PADDLE_HEIGHT(c_PADDLE_HEIGHT),
        .c_GAME_WINDOW_HEIGHT(30)
    ) paddle1_inst
    (
        .i_Clk(i_Clk),
        .i_ColCount_Div(w_ColCount_Div),
        .i_RowCount_Div(w_RowCount_Div),
        .i_Paddle_Up(i_Paddle_P1_Up),
        .i_Paddle_Down(i_Paddle_P1_Down),
        .o_DrawPaddle(w_DrawPaddle1),
        .o_Paddle_Y_position(w_Paddle1_Y_Pos)
    );

    pong_paddle_control #(
        .c_PADDLE_X_POSITION(39),
        .c_PADDLE_HEIGHT(c_PADDLE_HEIGHT),
        .c_GAME_WINDOW_HEIGHT(30)
    ) paddle2_inst
    (
        .i_Clk(i_Clk),
        .i_ColCount_Div(w_ColCount_Div),
        .i_RowCount_Div(w_RowCount_Div),
        .i_Paddle_Up(i_Paddle_P2_Up),
        .i_Paddle_Down(i_Paddle_P2_Down),
        .o_DrawPaddle(w_DrawPaddle2),
        .o_Paddle_Y_position(w_Paddle2_Y_Pos)
    );

    pong_ball_control #(
        .c_GAME_WINDOW_WIDTH(c_GAME_WINDOW_WIDTH),
        .c_GAME_WINDOW_HEIGHT(30)
    ) pong_ball_control_inst
    (
        .i_Clk(i_Clk),
        .i_GameRunning(w_GameRunning),
        .i_ColCount_Div(w_ColCount_Div),
        .i_RowCount_Div(w_RowCount_Div),
        .o_DrawBall(w_DrawBall),
        .o_Ball_X_Position(w_Ball_X_Pos),
        .o_Ball_Y_Position(w_Ball_Y_Pos)
    );

    pong_score_display #(
        .c_PONG_VISIBLE_COLUMNS(40),
        .c_PONG_VISIBLE_ROWS(30),
        .c_SCORE_BOARD_X_POS(14),
        .c_SCORE_BOARD_Y_POS(0)
    ) pong_score_P1_display_inst
    (
        .i_Clk(i_Clk),
        .i_ColCount_Div(w_ColCount_Div),
        .i_RowCount_Div(w_RowCount_Div),
        .i_ScoreCount(r_P1_ScoreCount),
        //.i_P2_ScoreCount(r_P2_ScoreCount),
        .o_DrawLetter(w_DrawScore_P1)
    );

    pong_score_display #(
        .c_PONG_VISIBLE_COLUMNS(40),
        .c_PONG_VISIBLE_ROWS(30),
        .c_SCORE_BOARD_X_POS(22),
        .c_SCORE_BOARD_Y_POS(0)
    ) pong_score_P2_display_inst
    (
        .i_Clk(i_Clk),
        .i_ColCount_Div(w_ColCount_Div),
        .i_RowCount_Div(w_RowCount_Div),
        .i_ScoreCount(r_P2_ScoreCount),
        //.i_P2_ScoreCount(r_P2_ScoreCount),
        .o_DrawLetter(w_DrawScore_P2)
    );

    ////////////////////////////////////////////////////////////////
    // For testing:
    //reg r_Switch_3_prev;
    //always @(posedge i_Clk) begin
    //    
    //    r_Switch_3_prev <= i_Paddle_P2_Up;

    //    if(i_Paddle_P2_Up == 1'b1 && r_Switch_3_prev == 1'b0) begin // Detect rising edge (switch press)
    //        if(r_P1_ScoreCount < 9) begin
    //            r_P1_ScoreCount <= r_P1_ScoreCount + 1;
    //            r_P2_ScoreCount <= 0;
    //        end
    //        else begin
    //            r_P1_ScoreCount <= 0;
    //        end
    //    end
    //    
    //end
    ////////////////////////////////////////////////////////////////

    always @(posedge i_Clk) begin
        
        if(w_ColCount_Div == c_PONG_NET_POSITION) begin
            if(w_RowCount_Div[0] == 1'b1) begin
                r_DrawNet <= 1'b1;
            end
            else begin
                r_DrawNet <= 1'b0;
            end
        end
        else begin
            r_DrawNet <= 1'b0;
        end

    end

    always @(posedge i_Clk) begin
        
        case(r_StateMachine_State)
            STATE_IDLE: begin

                if(i_StartGame == 1'b1) begin
                    r_StateMachine_State <= STATE_RUNNING;
                end
                
            end
            STATE_RUNNING: begin
             
                // Check if ball is at the side of player 1 paddle and if the paddle misses the ball
                if ((w_Ball_X_Pos == 0) && ((w_Ball_Y_Pos < w_Paddle1_Y_Pos) || (w_Ball_Y_Pos > w_Paddle1_Y_Pos + c_PADDLE_HEIGHT))) begin
                    r_StateMachine_State <= STATE_P2_SCORES;
                end
                else if ((w_Ball_X_Pos == c_GAME_WINDOW_WIDTH - 1) && ((w_Ball_Y_Pos < w_Paddle2_Y_Pos) || (w_Ball_Y_Pos > w_Paddle2_Y_Pos + c_PADDLE_HEIGHT))) begin
                    r_StateMachine_State <= STATE_P1_SCORES;
                end

            end
            STATE_P1_SCORES: begin
           
                // Check if the score count is allready one less than max
                if (r_P1_ScoreCount == c_SCORE_LIMIT - 1) begin
                    r_P1_ScoreCount <= 0;
                end
                else begin
                    r_P1_ScoreCount <= r_P1_ScoreCount + 1;
                    r_StateMachine_State <= STATE_CLEANUP;
                end

            end
            STATE_P2_SCORES: begin
 
                // Check if the score count is allready one less than max
                if (r_P2_ScoreCount == c_SCORE_LIMIT - 1) begin
                    r_P2_ScoreCount <= 0;
                end
                else begin
                    r_P2_ScoreCount <= r_P2_ScoreCount + 1;
                    r_StateMachine_State <= STATE_CLEANUP;
                end

               
            end
            STATE_CLEANUP: begin
                r_StateMachine_State <= STATE_IDLE;
            end
            default: begin
                r_StateMachine_State <= STATE_IDLE;
            end
        endcase
    end

    assign w_GameRunning = (r_StateMachine_State == STATE_RUNNING) ? 1'b1 : 1'b0; 

    // For testing:
    //assign w_DrawBall = (i_ColCount < 100 && i_RowCount > 250) ? 1'b1 : 1'b0;
    //assign w_DrawPaddle1 = 0;
    //assign w_DrawPaddle2 = 0;

    assign o_P1_ScoreCount = r_P1_ScoreCount;
    assign o_P2_ScoreCount = r_P2_ScoreCount;

    assign w_DrawCurrentPixel = w_DrawPaddle1 | w_DrawPaddle2 | w_DrawBall | w_DrawScore_P1 | w_DrawScore_P2 | r_DrawNet;
    //assign w_DrawCurrentPixel = w_DrawPaddle1 | w_DrawPaddle2 | w_DrawBall;

    // Draw using white color
    // The screen might display black even if you try to draw white if you draw outside the borders
    //assign o_VideoRed = w_DrawCurrentPixel ? 3'b111 : 3'b000;
    //assign o_VideoGreen = w_DrawCurrentPixel ? 3'b111 : 3'b000;
    //assign o_VideoBlue = w_DrawCurrentPixel ? 3'b111 : 3'b000;

    assign o_VideoRed = w_DrawCurrentPixel ? (w_DrawScore_P1 ? 3'b111 :   (w_DrawScore_P2 ? 3'b111 : (w_DrawBall ? 3'b000 : 3'b111))) : 3'b000;
    assign o_VideoGreen = w_DrawCurrentPixel ? (w_DrawScore_P1 ? 3'b000 : (w_DrawScore_P2 ? 3'b111 : (w_DrawBall ? 3'b000 : 3'b111))) : 3'b000;
    assign o_VideoBlue = w_DrawCurrentPixel ? (w_DrawScore_P1 ? 3'b000 :  (w_DrawScore_P2 ? 3'b000 : (w_DrawBall ? 3'b111 : 3'b111))) : 3'b000;


    // For testing:
    //assign o_VideoRed = (i_ColCount < c_VISIBLE_COLUMNS && i_RowCount < c_VISIBLE_ROWS) ? 3'b111 : 3'b000;
    //assign o_VideoGreen = (i_ColCount < c_VISIBLE_COLUMNS && i_RowCount < c_VISIBLE_ROWS) ? 3'b000 : 3'b000;
    //assign o_VideoBlue = (i_ColCount < c_VISIBLE_COLUMNS && i_RowCount < c_VISIBLE_ROWS) ? 3'b111 : 3'b000;

endmodule
