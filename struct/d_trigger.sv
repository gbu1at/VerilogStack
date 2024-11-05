import sync_rs_trigger::*;
import and::*;
import not::*;

module d_trigger (
    input wire d,
    input wire sync,
    output wire q,
    output wire neq_q
) (
    wire not_d;
    not (
        d, not_d
    );

    sync_rs_trigger (
        not_d, sync, d, q, neg_q
    )
);
    
endmodule