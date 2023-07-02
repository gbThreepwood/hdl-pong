`default_nettype none

module uart_rx #(
    parameter CLKS_PER_BIT = 217
)(
    input wire i_Rst_L,
    input wire i_Clk,
    input wire i_RX_Serial,
    output reg o_RX_DV,         // Data vaild (DV) flag (high for one clock cycle)
    output reg [7:0] o_RX_Byte
);

// States
localparam IDLE         = 3'b000;
localparam RX_START_BIT = 3'b001;
localparam RX_DATA_BITS = 3'b010;
localparam RX_STOP_BIT  = 3'b011;
localparam FINISH       = 3'b100;

reg [2:0] r_RX_State;
reg [2:0] r_Bit_Index;
reg [9:0] r_Clock_Count;

initial begin
    o_RX_DV <= 1'b0;
    o_RX_Byte <= 0;
end

always @(posedge i_Clk or negedge i_Rst_L) begin

    if(~i_Rst_L) begin
        r_RX_State <= IDLE;
        o_RX_DV <= 1'b0;
    end
    else begin
        case (r_RX_State)
        IDLE:
            begin
                o_RX_DV <= 1'b0;
                r_Clock_Count <= 1'b0;
                r_Bit_Index   <= 1'b0;
                
                if(i_RX_Serial == 1'b0) begin // Detect the start bit (line has recently gone from high to low)
                    o_RX_Byte <= 0;
                    r_RX_State <= RX_START_BIT;
                end
                else begin
                    r_RX_State <= IDLE;
                end
            end

            // Wait until the middle of the start bit and sample it again
            // If it is still low we star receiving the data bits
        RX_START_BIT:
            begin

                if(r_Clock_Count == (CLKS_PER_BIT - 1)/2) begin
                    if(i_RX_Serial == 1'b0) begin
                        r_Clock_Count <= 1'b0;
                        r_RX_State <= RX_DATA_BITS;
                    end
                    else begin
                        r_RX_State <= IDLE;
                    end
                end
                else begin
                    r_Clock_Count <= r_Clock_Count + 1;
                end

            end

            // We enter this state from RX_START_BIT at the middle of the start bit
            // Thus we should wait CLKS_PER_BIT clock cycles before we sample the first data bit 
        RX_DATA_BITS:
            begin

                if(r_Clock_Count == (CLKS_PER_BIT - 1)) begin
                    r_Clock_Count <= 1'b0;

                    o_RX_Byte[r_Bit_Index] <= i_RX_Serial;

                    if(r_Bit_Index < 7) begin
                        r_Bit_Index <= r_Bit_Index + 1;
                    end
                    else begin
                        r_Bit_Index <= 1'b0;
                        r_RX_State <= RX_STOP_BIT;
                    end
                end
                else begin
                    r_Clock_Count <= r_Clock_Count + 1;
                end

            end

            // The stop bit should be high
        RX_STOP_BIT:
            begin

                if(r_Clock_Count == (CLKS_PER_BIT - 1)) begin
                    r_Clock_Count <= 1'b0;
                    o_RX_DV = 1'b1; // Signal that one byte has been received
                    r_RX_State <= FINISH;
                end
                else begin
                    r_Clock_Count <= r_Clock_Count + 1;
                end

            end

        FINISH:
            begin
                r_RX_State <= IDLE;
                o_RX_DV    <= 1'b0;
            end
        default:
            r_RX_State <= IDLE;
        endcase
    end

end

endmodule
