`include "stack_behaviour.sv"


// `define NOP 2'b00
// `define PUSH 2'b01 
// `define POP 2'b10
// `define GET 2'b11


module stack_behaviour_tb;
    wire[3:0] IO_DATA;
    reg[3:0] INPUT;
    reg RESET;
    reg CLK;
    reg[1:0] COMMAND;
    reg[2:0] INDEX;
    

    stack_behaviour_normal stack(IO_DATA, RESET, CLK, COMMAND, INDEX);

    assign IO_DATA = COMMAND[1] ? 4'bz : INPUT;

    always @(posedge CLK or RESET) #1 $display("%0t\t%b\t%b\t%d\t%d\t %b", $time - 1, RESET, CLK, COMMAND, INDEX, IO_DATA);

    initial begin
        $display("check 0");
        $display(" t\trst\tclk\tcmd\tind\t io_data");
        RESET = 0; CLK = 0; COMMAND = 0; INDEX = 0; INPUT = 0;
        #2; CLK=1;
        #2; CLK=0;
        
        // check 1: push one element, pop 6 times
        #4; $display("check 1");
        $display(" t\trst\tclk\tcmd\tind\t io_data");
        #1; COMMAND <= 1; INPUT <= 4'b1111;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;
        
        // check 2: push one element, reset with clk = 1, check pop gives pushed element, pop 4 times to see nothing else
        #4; $display("check 2");
        $display(" t\trst\tclk\tcmd\tind\t io_data");
        #1; COMMAND <= 1; INPUT <= 4'b1010;
        #1; CLK=1;
        #2; RESET = 1;
        #2; RESET = 0;
        #2; CLK = 0;

        
        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;


        //check 3: reset, pop 5 times to see that stack is clean
        #4; $display("check 3");
        $display(" t\trst\tclk\tcmd\tind\t io_data");
        #2; RESET = 1;
        #2; RESET = 0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;   

        //check 4: push 5 different values, pop 5 times, get 8 times with ind = 0..7
        #4; $display("check 4");
        $display(" t\trst\tclk\tcmd\tind\t io_data");
        //stack still filled with 0.
        #1; COMMAND <= 1; INPUT <= 4'b1111;
        #1; CLK=1;
        #2; CLK=0;
        
        #1; COMMAND <= 1; INPUT <= 4'b1110;
        #1; CLK=1;
        #2; CLK=0;
        
        #1; COMMAND <= 1; INPUT <= 4'b1101;
        #1; CLK=1;
        #2; CLK=0;
        
        #1; COMMAND <= 1; INPUT <= 4'b1011;
        #1; CLK=1;
        #2; CLK=0;
        
        #1; COMMAND <= 1; INPUT <= 4'b0111;
        #1; CLK=1;
        #2; CLK=0;

        // #2; $display("\tpush finish, start pop");

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 2;
        #1; CLK=1;
        #2; CLK=0;

        // #2; $display("\tpop finish, start get");

        #1; COMMAND <= 3; INDEX <= 0;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 3; INDEX <= 1;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 3; INDEX <= 2;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 3; INDEX <= 3;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 3; INDEX <= 4;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 3; INDEX <= 5;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 3; INDEX <= 6;
        #1; CLK=1;
        #2; CLK=0;

        #1; COMMAND <= 3; INDEX <= 7;
        #1; CLK=1;
        #2; CLK=0;
    end
    
endmodule
