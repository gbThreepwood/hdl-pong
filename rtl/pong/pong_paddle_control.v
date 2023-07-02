`default_nettype none

module pong_paddle_control #(
    parameter c_PADDLE_X_POSITION = 0,
    parameter c_PADDLE_HEIGHT = 6,
    parameter c_GAME_WINDOW_HEIGHT = 30
)
(
    input wire i_Clk,
    input wire [5:0] i_ColCount_Div,
    input wire [5:0] i_RowCount_Div,
    input wire i_Paddle_Up,
    input wire i_Paddle_Down,
    output reg o_DrawPaddle,
    output reg [5:0] o_Paddle_Y_position = 0
);

    // The system clock is 25 MHz, which means that one clock cycle is 1/25 Mhz = 40 ns
    // If we choose to have a 50 ms delay between each paddle movement we get 50 ms / 40 ns = 1250000 clock cycles
    localparam c_PADDLE_DELAY_CYCLES= 1250000;

    reg [31:0] r_PaddleDelayCounter = 0;
    wire w_Paddle_Command_Valid;
    assign w_Paddle_Command_Valid = i_Paddle_Up ^ i_Paddle_Down;

    always @(posedge i_Clk) begin
        
        if (w_Paddle_Command_Valid == 1'b1) begin
            if (r_PaddleDelayCounter == c_PADDLE_DELAY_CYCLES) begin
                r_PaddleDelayCounter <= 0;
            end
            else begin
               r_PaddleDelayCounter <= r_PaddleDelayCounter + 1; 
            end
        end

        if ((r_PaddleDelayCounter == c_PADDLE_DELAY_CYCLES) && (o_Paddle_Y_position != (c_GAME_WINDOW_HEIGHT - c_PADDLE_HEIGHT - 1)) && (i_Paddle_Down == 1'b1)) begin
            o_Paddle_Y_position <= o_Paddle_Y_position + 1;
        end
        else if ((r_PaddleDelayCounter == c_PADDLE_DELAY_CYCLES) && (o_Paddle_Y_position != 0) && (i_Paddle_Up == 1'b1)) begin
            o_Paddle_Y_position <= o_Paddle_Y_position - 1;
        end

    end

    always @(posedge i_Clk) begin
    
        if((i_ColCount_Div == c_PADDLE_X_POSITION) && (i_RowCount_Div >= o_Paddle_Y_position) && (i_RowCount_Div <= o_Paddle_Y_position + c_PADDLE_HEIGHT)) begin
            o_DrawPaddle <= 1'b1;
        end
        else begin
            o_DrawPaddle <= 1'b0;
        end

    end

endmodule
