import nor::*;

module rs_trigger (
    input wire r,
    input wire s,
    output wire q,
    output wire neg_q;
) (
    nor (r, neg_q, q);
    nor (s, q, neg_q);
);
    
endmodule