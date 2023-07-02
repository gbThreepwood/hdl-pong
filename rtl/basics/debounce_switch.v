module debounce_switch(input i_Clk, input i_Switch, output o_Switch);

    parameter c_DEBOUNCE_LIMIT = 250000; // Clock is 25 MHz which gives 250000/25000000 = 0.01 s = 10 ms

    reg [17:0] r_Count = 0;
    reg r_State = 1'b0;

    always @(posedge i_Clk) begin
        if (i_Switch !== r_State && r_Count < c_DEBOUNCE_LIMIT)
        begin
            r_Count <= r_Count + 1;
        end
        else if (r_Count == c_DEBOUNCE_LIMIT)
        begin
            r_State = i_Switch;
            r_Count = 0;
        end
        else
        begin
            r_Count <= 0;
        end
                
    end

    assign o_Switch = r_State;
endmodule