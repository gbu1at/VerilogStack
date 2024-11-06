module main;
    reg z = 1'b0;
    reg d = 1'b1;

    wire x;
    and(x, d, z);


    initial begin
        #100; z = 1'bz;
        #100; d = 1'b1;
    end

    always @(*) $display("%0t \t %d", $time, x);

endmodule


