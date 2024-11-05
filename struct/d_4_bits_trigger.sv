import d_trigger::*;
import and::*;
import or::*;
import not::*;

module d_4_bits_trigger (
    input wire reset,
    input wire sync,
    input wire [3:0] d,
    output wire [3:0] q,
) (

    wire new_sync;
    or (
        sync, reset
    );

    wire not_reset;
    not (
        reset, 
        not_reset
    );


    wire [3:0] extend_reset;
    assign extend_reset[0] = not_reset;
    assign extend_reset[1] = not_reset;
    assign extend_reset[2] = not_reset;
    assign extend_reset[3] = not_reset;

    wire [3:0] new_d = extend_reset & d;

    d_trigger (
        new_d[0], new_sync, q[0]
    );
    
    d_trigger (
        new_d[1], new_sync, q[1]
    );
    
    d_trigger (
        new_d[2], new_sync, q[2]
    );

    d_trigger (
        new_d[3], new_sync, q[3]
    );

);
    
endmodule