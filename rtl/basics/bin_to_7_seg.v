`default_nettype none

module bin_to_7_seg(
    input wire[3:0]  i_bin_num,
    input wire       i_enable,
    input wire       i_invert,
    output wire[6:0] o_out_seg
);

    reg [6:0] r_segments = 7'b000_0000;

    always @(*) begin
        r_segments = 7'b000_0000;
        if(i_enable) begin
            case(i_bin_num)
                4'h0   : r_segments = 7'b011_1111;
                4'h1   : r_segments = 7'b000_0110;
                4'h2   : r_segments = 7'b101_1011;
                4'h3   : r_segments = 7'b100_1111;
                4'h4   : r_segments = 7'b110_0110;
                4'h5   : r_segments = 7'b110_1101;
                4'h6   : r_segments = 7'b111_1101;
                4'h7   : r_segments = 7'b000_0111;
                4'h8   : r_segments = 7'b111_1111;
                4'h9   : r_segments = 7'b110_1111;
                4'hA   : r_segments = 7'b111_0111;
                4'hB   : r_segments = 7'b111_1100;
                4'hC   : r_segments = 7'b011_1001;
                4'hD   : r_segments = 7'b101_1110;
                4'hE   : r_segments = 7'b111_1001;
                4'hF   : r_segments = 7'b111_0001;
            default: begin
                r_segments = 7'b000_0000;
            end
            endcase
        end
    end

    assign o_out_seg = i_invert ? ~r_segments : r_segments;

endmodule
