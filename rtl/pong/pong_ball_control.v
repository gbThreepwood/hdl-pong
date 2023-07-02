`default_nettype none

module pong_ball_control #(
    parameter c_GAME_WINDOW_WIDTH = 40,
    parameter c_GAME_WINDOW_HEIGHT = 30
)
(
    input wire i_Clk,
    input wire i_GameRunning,
    input wire [5:0] i_ColCount_Div,
    input wire [5:0] i_RowCount_Div,
    output reg o_DrawBall,
    output reg [5:0] o_Ball_X_Position = 0,
    output reg [5:0] o_Ball_Y_Position = 0
);

    // The system clock is 25 MHz, which means that one clock cycle is 1/25 Mhz = 40 ns
    // If we choose to have a 50 ms delay between each ball movement we get 50 ms / 40 ns = 1250000 clock cycles
    localparam c_BALL_DELAY_CYCLES= 1250000;

    reg [5:0] r_Ball_Prev_X_Pos = 0;
    reg [5:0] r_Ball_Prev_Y_Pos = 0;
    reg [31:0] r_BallDelayCounter = 0;

    always @(posedge i_Clk) begin
        
        if(i_GameRunning == 1'b0) begin
            o_Ball_X_Position <= c_GAME_WINDOW_WIDTH / 2;
            o_Ball_Y_Position <= c_GAME_WINDOW_HEIGHT / 2;
            r_Ball_Prev_X_Pos <= c_GAME_WINDOW_WIDTH / 2 + 1;
            r_Ball_Prev_Y_Pos <= c_GAME_WINDOW_HEIGHT / 2 - 1;
        end
        else begin

            if (r_BallDelayCounter == c_BALL_DELAY_CYCLES) begin
                r_BallDelayCounter <= 0;

                // Store previous ball position in order to determine movement direction
                r_Ball_Prev_X_Pos <= o_Ball_X_Position;
                r_Ball_Prev_Y_Pos <= o_Ball_Y_Position;

                if (((r_Ball_Prev_X_Pos < o_Ball_X_Position) && (o_Ball_X_Position == c_GAME_WINDOW_WIDTH - 1)) || ((r_Ball_Prev_X_Pos > o_Ball_X_Position) && (o_Ball_X_Position != 0))) begin
                    o_Ball_X_Position <= o_Ball_X_Position - 1;
                end
                else begin
                    o_Ball_X_Position <= o_Ball_X_Position + 1;
                end

                if (((r_Ball_Prev_Y_Pos < o_Ball_Y_Position) && (o_Ball_Y_Position == c_GAME_WINDOW_HEIGHT - 1)) || ((r_Ball_Prev_Y_Pos > o_Ball_Y_Position) && (o_Ball_Y_Position != 0))) begin
                    o_Ball_Y_Position <= o_Ball_Y_Position - 1;
                end
                else begin
                    o_Ball_Y_Position <= o_Ball_Y_Position + 1;
                end

            end
            else begin
                r_BallDelayCounter <= r_BallDelayCounter + 1;
            end
        end

    end

    always @(posedge i_Clk) begin
        
        if ((i_ColCount_Div == o_Ball_X_Position) && (i_RowCount_Div == o_Ball_Y_Position)) begin
            o_DrawBall = 1'b1;
        end
        else begin
            o_DrawBall = 1'b0;
        end
    end

endmodule
