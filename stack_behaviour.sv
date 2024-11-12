
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
        stack[0] = 0;
        stack[1] = 0;
        stack[2] = 0;
        stack[3] = 0;
        stack[4] = 0;
        curr_idx = 4'b0000;
        o_data = 4'b0000;
    end
    reg [2:0] i;
    reg [3:0] shift_indx;
    always @(posedge CLK, RESET) begin
        if (RESET == 1) begin
            stack[0] = 0;
            stack[1] = 0;
            stack[2] = 0;
            stack[3] = 0;
            stack[4] = 0;
            curr_idx = 4'b0000; 
            o_data = 4'b0000;
        end

        else begin
            if (COMMAND == 2'b00) begin 
            end
            if (COMMAND == 2'b01) begin
                curr_idx += 1;
                if (curr_idx == 4'b0101)
                    curr_idx = 0;
                stack[curr_idx] = IO_DATA;
            end
            if (COMMAND == 2'b10) begin
                o_data = stack[curr_idx];
                if (curr_idx == 0) curr_idx = 4'b0101;
                curr_idx -= 1;
            end
            if (COMMAND == 2'b11) begin
                i = INDEX;
                if (i == 3'b111) i = 3'b010;
                if (i == 3'b110) i = 3'b001;
                i = 5 - i;
                shift_indx = curr_idx + i;
                if (shift_indx == 4'b1001) shift_indx = 4'b0100;
                if (shift_indx == 4'b1000) shift_indx = 4'b0011;
                if (shift_indx == 4'b0111) shift_indx = 4'b0010;
                if (shift_indx == 4'b0110) shift_indx = 4'b0001;
                if (shift_indx == 4'b0101) shift_indx = 4'b0000;
                o_data = stack[shift_indx];
            end
        end
    end
endmodule
