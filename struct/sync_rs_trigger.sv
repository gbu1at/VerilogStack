import rs_trigger::*;
import and::*;

module sync_rs_trigger (
    input wire r,
    input wire sync,
    input wire s,
    output wire q,
    output wire neg_q;
) (
    wire new_r;
    and (
        r, sync, new_r
    );
    wire new_s;
    and (
        s, sync, new_s
    );

    rs_trigger (
        new_r, new_s, q, neg_q
    );
);
    
endmodule