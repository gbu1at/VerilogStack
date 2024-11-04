
module stack_behaviour_normal (
    input wire [3:0] IO_DATA,
    input wire RESET, 
    input wire CLK, 
    input wire [1:0] COMMAND, 
    input wire [2:0] INDEX
);
    reg [3:0] stack [4:0];
    reg [2:0] current_index;
    reg [3:0] out_data;
    assign IO_DATA = (COMMAND[1] == 1) ? out_data : 'z;

    initial begin
        for (int i = 0; i < 5; ++i) 
            stack[i] = 0;
        current_index = 3'b000;
        out_data = 4'b0000;
    end


    always @(posedge CLK, RESET) begin
        if (RESET == 1) begin
            for (int i = 0; i < 5; ++i) 
                stack[i] = 0;
            current_index = 3'b000; 
            out_data = 4'b0000;
        end

        else begin
            if (COMMAND == 2'b00) begin 

            end
            if (COMMAND == 2'b01) begin
                current_index += 1;
                current_index %= 5;
                stack[current_index] = IO_DATA;
            end
            if (COMMAND == 2'b10) begin
                out_data = stack[current_index];
                if (current_index == 3'b000) current_index = 3'b101;
                current_index -= 1;
            end
            if (COMMAND == 2'b11) begin 
                out_data = stack[(4'b0000 + current_index + INDEX) % 5];
            end
        end
    end


endmodule