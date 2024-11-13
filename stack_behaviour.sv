module stack_behaviour_normal (
    inout wire [3:0] IO_DATA,
    input wire RESET, 
    input wire CLK, 
    input wire [1:0] COMMAND, 
    input wire [2:0] INDEX
);
    reg [3:0] curr_idx;
    reg [3:0] stack [4:0];
    reg [3:0] o_data;
    assign IO_DATA = ((COMMAND[1] == 0 || CLK == 1'b0) ? 'z : o_data);
    initial begin
        stack[0] = 0;
        stack[1] = 0;
        stack[2] = 0;
        stack[3] = 0;
        stack[4] = 0;
        curr_idx = 4'b0000;
        o_data = 4'b0000;
    end

    reg [2:0] i;

    reg is_push = 0;
    reg is_pop = 0;

    always @(RESET, CLK, INDEX, COMMAND, IO_DATA) begin
        if (RESET == 1) begin
            stack[0] = 0;
            stack[1] = 0;
            stack[2] = 0;
            stack[3] = 0;
            stack[4] = 0;
            curr_idx = 4'b0000; 
            o_data = 4'b0000;
            is_push = 0;
            is_pop = 0;
        end
        else if (CLK == 0) begin
            is_push = 0;
            is_pop = 0;
        end
        else if (CLK == 1) begin
            if (COMMAND == 2'b00) begin 
            end
            if (COMMAND == 2'b01) begin
                if (is_push == 0) begin
                    curr_idx += 1;
                    curr_idx %= 5;
                    stack[curr_idx] = IO_DATA;
                    is_push = 1;
                end
                else begin 
                    stack[curr_idx] = IO_DATA;
                end
            end
            if (COMMAND == 2'b10) begin
                if (is_pop == 0) begin
                    o_data = stack[curr_idx];
                    curr_idx += 4;
                    curr_idx %= 5;
                    is_pop = 1;
                end
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