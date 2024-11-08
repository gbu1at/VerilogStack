
module stack_behaviour_normal (
    input wire [3:0] IO_DATA,
    input wire RESET, 
    input wire CLK, 
    input wire [1:0] COMMAND, 
    input wire [2:0] INDEX
);
    reg [3:0] curr_idx;
    reg [3:0] stack [4:0];
    reg [3:0] o_data;

    assign IO_DATA = (COMMAND[1] == 0 || CLK == 1'b0) ? 'z : o_data;

    initial begin
        for (int i = 0; i < 5; ++i) 
            stack[i] = 0;
        curr_idx = 4'b0000;
        o_data = 4'b0000;
    end
    reg [2:0] i;
    always @(posedge CLK, RESET) begin
        if (RESET == 1) begin
            for (int i = 0; i < 5; ++i) 
                stack[i] = 0;
            curr_idx = 4'b0000; 
            o_data = 4'b0000;
        end

        else begin
            if (COMMAND == 2'b00) begin 
            end
            if (COMMAND == 2'b01) begin
                curr_idx += 1;
                curr_idx %= 5;
                stack[curr_idx] = IO_DATA;
            end
            if (COMMAND == 2'b10) begin
                o_data = stack[curr_idx];
                curr_idx += 4;
                curr_idx %= 5;
            end
            if (COMMAND == 2'b11) begin
                i = INDEX;
                i %= 5;
                i = 5 - i;
                o_data = stack[(curr_idx + i) % 5];
            end
        end
    end
endmodule
