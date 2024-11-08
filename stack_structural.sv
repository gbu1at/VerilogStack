module and4(
    input wire [3:0] a,
    input wire [3:0] b,
    output wire [3:0] q
);
    and(q[0], a[0], b[0]);
    and(q[1], a[1], b[1]);
    and(q[2], a[2], b[2]);
    and(q[3], a[3], b[3]);

endmodule

module or4(
    input wire [3:0] a,
    input wire [3:0] b,
    output wire [3:0] q
);
    or(q[0], a[0], b[0]);
    or(q[1], a[1], b[1]);
    or(q[2], a[2], b[2]);
    or(q[3], a[3], b[3]);

endmodule

module rs_trigger (
    input wire r,
    input wire s,
    output wire q,
    output wire neg_q
);
    wire n1, n2;
    nor(q, neg_q, r);
    nor(neg_q, q, s);
endmodule

module sync_rs_trigger (
    input wire r,
    input wire sync,
    input wire s,
    output wire q,
    output wire neg_q
);
    wire new_r;
    and(new_r, r, sync);
    
    wire new_s;
    and(new_s, s, sync);

    rs_trigger rs_inst (.r(new_r), .s(new_s), .q(q), .neg_q(neg_q));
endmodule

module d_trigger (
    input wire d,
    input wire sync,
    output wire q
);
    wire not_d;
    
    not(not_d, d);

    wire neg_q;

    sync_rs_trigger sync_inst (.r(not_d), .sync(sync), .s(d), .q(q), .neg_q(neg_q));

endmodule

module d_2_bits_trigger (
    input wire reset,
    input wire sync,
    input wire [1:0] d,
    output wire [1:0] q
);
    
    wire new_sync;
    
    or(new_sync, reset, sync);

    wire not_reset;
    not(not_reset, reset);

    wire [1:0] extend_reset;
    
    assign extend_reset = {not_reset, not_reset};

    wire [1:0] new_d;

    and(new_d[0], d[0], extend_reset[0]);
    and(new_d[1], d[1], extend_reset[1]);


    d_trigger d0 (.d(new_d[0]), .sync(new_sync), .q(q[0]));
    
    d_trigger d1 (.d(new_d[1]), .sync(new_sync), .q(q[1]));

endmodule

module d_4_bits_trigger (
    input wire reset,
    input wire sync,
    input wire [3:0] d,
    output wire [3:0] q
);
    
    wire new_sync;
    
    or(new_sync, reset, sync);

    wire not_reset;
    not(not_reset, reset);

    wire [3:0] extend_reset;
    
    assign extend_reset = {not_reset, not_reset, not_reset, not_reset};

    wire [3:0] new_d;
    and(new_d[0], d[0], extend_reset[0]);
    and(new_d[1], d[1], extend_reset[1]);
    and(new_d[2], d[2], extend_reset[2]);
    and(new_d[3], d[3], extend_reset[3]);


    d_trigger d0 (.d(new_d[0]), .sync(new_sync), .q(q[0]));
    
    d_trigger d1 (.d(new_d[1]), .sync(new_sync), .q(q[1]));
    
    d_trigger d2 (.d(new_d[2]), .sync(new_sync), .q(q[2]));

    d_trigger d3 (.d(new_d[3]), .sync(new_sync), .q(q[3]));

endmodule



module d_3_bits_trigger (
    input wire reset,
    input wire sync,
    input wire [2:0] d,
    output wire [2:0] q
);
    wire [3:0] extend_q;
    wire [3:0] extend_d = {1'b0, d[2], d[1], d[0]};
    d_4_bits_trigger trigger (
        .reset(reset),
        .sync(sync),
        .d(extend_d),
        .q(extend_q)
    );
    assign q[2:0] = {extend_q[2], extend_q[1], extend_q[0]};

endmodule

module dec_3_8 (
    input wire [2:0] a,
    output wire [7:0] q
);

    assign q[0] = (a == 3'b000) ? 1'b1 : 1'b0;
    assign q[1] = (a == 3'b001) ? 1'b1 : 1'b0;
    assign q[2] = (a == 3'b010) ? 1'b1 : 1'b0;
    assign q[3] = (a == 3'b011) ? 1'b1 : 1'b0;
    assign q[4] = (a == 3'b100) ? 1'b1 : 1'b0;
    assign q[5] = (a == 3'b101) ? 1'b1 : 1'b0;
    assign q[6] = (a == 3'b110) ? 1'b1 : 1'b0;
    assign q[7] = (a == 3'b111) ? 1'b1 : 1'b0;

endmodule

module half_adder (
    input wire a,
    input wire b,
    output wire sum,
    output wire carry
);
    xor(sum, a, b);
    and(carry, a, b);
endmodule


module full_adder (
    input wire a,
    input wire b,
    input wire carry_in,
    output wire sum,
    output wire carry_out
);
    wire sum_half;
    wire carry_half1;
    wire carry_half2;

    half_adder HA1 (
        .a(a), 
        .b(b), 
        .sum(sum_half), 
        .carry(carry_half1)
    ); 
    half_adder HA2 (
        .a(sum_half), 
        .b(carry_in), 
        .sum(sum), 
        .carry(carry_half2)
    );
    or(carry_out, carry_half1, carry_half2);

endmodule


module three_bit_adder (
    input wire [2:0] a,
    input wire [2:0] b,
    output wire [3:0] s
);
    wire c1, c2;
    wire [2:0] sum;

    full_adder FA0 (
        .a(a[0]), 
        .b(b[0]), 
        .carry_in(1'b0), 
        .sum(sum[0]), 
        .carry_out(c1)
    );
    
    full_adder FA1 (
        .a(a[1]), 
        .b(b[1]), 
        .carry_in(c1), 
        .sum(sum[1]), 
        .carry_out(c2)
    );
    
    full_adder FA2 (
        .a(a[2]), 
        .b(b[2]), 
        .carry_in(c2), 
        .sum(sum[2]), 
        .carry_out(s[3])
    );

    assign s[2:0] = sum;

endmodule


module four_bit_adder (
    input wire [3:0] a,
    input wire [3:0] b,
    output wire [4:0] s
);
    wire c1, c2;
    wire [3:0] sum;

    three_bit_adder tba (
        .a({a[2], a[1], a[0]}), 
        .b({b[2], b[1], b[0]}), 
        .s(sum)
    );
    
    full_adder FA (
        .a(a[3]), 
        .b(b[3]), 
        .carry_in(sum[3]), 
        .sum(s[3]), 
        .carry_out(s[4])
    );

    assign s[2:0] = {sum[2], sum[1], sum[0]};

endmodule


module five_bit_adder (
    input wire [4:0] a,
    input wire [4:0] b,
    output wire [5:0] s
);
    wire [4:0] sum;

    four_bit_adder tba (
        .a({a[3], a[2], a[1], a[0]}), 
        .b({b[3], b[2], b[1], b[0]}), 
        .s(sum)
    );
    
    full_adder FA (
        .a(a[4]), 
        .b(b[4]), 
        .carry_in(sum[4]), 
        .sum(s[4]), 
        .carry_out(s[5])
    );

    assign s[3:0] = {sum[3], sum[2], sum[1], sum[0]};

endmodule


module neg_5_bits (
    input wire [4:0] a,
    output wire [4:0] q
);
    wire [4:0] not_a;
    not(not_a[0], a[0]);
    not(not_a[1], a[1]);
    not(not_a[2], a[2]);
    not(not_a[3], a[3]);
    not(not_a[4], a[4]);

    wire [4:0] const_1 = 5'b00001;

    wire [5:0] ext_s;

    five_bit_adder fba(
        .a(not_a),
        .b(const_1),
        .s(ext_s)
    );

    assign q = ext_s[4:0];

endmodule


module is_more_5(
    input wire [4:0] a,
    output wire q
);
    wire [4:0] const_5 = 5'b00101;
    wire [4:0] neg_five;

    neg_5_bits n5(
        .a(const_5),
        .q(neg_five)
    );

    wire [5:0] sum;


    five_bit_adder fba (
        .a(neg_five),
        .b(a),
        .s(sum)
    );
    not(q, sum[4]);

endmodule



module is_more_10(
    input wire [4:0] a,
    output wire q
);
    wire [4:0] const_10 = 5'b01010;
    wire [4:0] neg_ten;

    neg_5_bits n5(
        .a(const_10),
        .q(neg_ten)
    );

    wire [5:0] sum;


    five_bit_adder fba (
        .a(neg_ten),
        .b(a),
        .s(sum)
    );
    not(q, sum[4]);

endmodule

module mod5 (
    input wire [3:0] a,
    output wire [2:0] q
);

    wire [4:0] const_five = 5'b00101;
    wire [4:0] neg_five;
    neg_5_bits nn5 (
        .a(const_five),
        .q(neg_five)
    );

    wire [4:0] const_ten = 5'b01010;
    wire [4:0] neg_ten;
    neg_5_bits nn10 (
        .a(const_ten),
        .q(neg_ten)
    );

    wire [4:0] extend_a;
    assign extend_a[3:0] = a;
    assign extend_a[4] = 1'b0;

    wire is_more_10;
    is_more_10 ism10(
        .a(extend_a),
        .q(is_more_10)
    );

    wire [4:0] extend_ism10 = {is_more_10, is_more_10, is_more_10, is_more_10, is_more_10};

    wire [4:0] and_neg_10_is_more_10;

    and(and_neg_10_is_more_10[0], neg_ten[0], extend_ism10[0]);
    and(and_neg_10_is_more_10[1], neg_ten[1], extend_ism10[1]);
    and(and_neg_10_is_more_10[2], neg_ten[2], extend_ism10[2]);
    and(and_neg_10_is_more_10[3], neg_ten[3], extend_ism10[3]);
    and(and_neg_10_is_more_10[4], neg_ten[4], extend_ism10[4]);


    wire [5:0] extend_sum1;

    five_bit_adder fba(
        .a(extend_a),
        .b(and_neg_10_is_more_10),
        .s(extend_sum1)
    );

    wire [4:0] sum1 = extend_sum1[4:0];

    wire is_more_5_2;
    is_more_5 ism52(
        .a(sum1),
        .q(is_more_5_2)
    );

    wire [4:0] extend_ism52 = {is_more_5_2, is_more_5_2, is_more_5_2, is_more_5_2, is_more_5_2};

    wire [4:0] and_neg_5_is_m2;

    and(and_neg_5_is_m2[0], neg_five[0], extend_ism52[0]);
    and(and_neg_5_is_m2[1], neg_five[1], extend_ism52[1]);
    and(and_neg_5_is_m2[2], neg_five[2], extend_ism52[2]);
    and(and_neg_5_is_m2[3], neg_five[3], extend_ism52[3]);
    and(and_neg_5_is_m2[4], neg_five[4], extend_ism52[4]);

    wire [5:0] extend_sum2;

    five_bit_adder fba2(
        .a(sum1),
        .b(and_neg_5_is_m2),
        .s(extend_sum2)
    );

    wire [4:0] sum2 = extend_sum2[4:0];

    assign q = sum2[2:0];

endmodule

module next_index (
    input wire [1:0] cmd,
    input wire sync,
    input wire [2:0] index,
    output wire [2:0] next_idx
);
    wire c0 = cmd[0];
    wire c1 = cmd[1];

    wire or_c0_c1;

    or(or_c0_c1, c0, c1);

    wire [3:0] cmd_val;

    and(cmd_val[0], or_c0_c1, c0);
    and(cmd_val[2], or_c0_c1, c1);

    assign cmd_val[1] = 1'b0;
    assign cmd_val[3] = 1'b0;

    wire [2:0] S;
    and(S[0], sync, cmd_val[0]);
    and(S[1], sync, cmd_val[1]);
    and(S[2], sync, cmd_val[2]);

    wire [3:0] sum;

    three_bit_adder tba (
        .a(index),
        .b(S),
        .s(sum)
    );

    mod5 m2 (
        .a(sum),
        .q(next_idx)
    );

endmodule



module current_index (
    input wire reset,
    input wire [1:0] cmd,
    input wire sync,
    output wire [2:0] q
);
    wire [2:0] next_idx;
    wire not_sync;

    not(not_sync, sync);

    wire [2:0] trigger1_out;

    d_3_bits_trigger trigger1 (
        .reset(reset),
        .sync(sync),
        .d(next_idx),
        .q(trigger1_out)
    );


    wire [2:0] trigger2_out;

    d_3_bits_trigger trigger2 (
        .reset(reset),
        .sync(not_sync),
        .d(trigger1_out),
        .q(trigger2_out)
    );


    next_index nxi (
        .cmd(cmd),
        .sync(sync),
        .index(trigger2_out),
        .next_idx(next_idx)
    );

    assign q = next_idx;


endmodule




module memory (
    input wire reset,
    input wire sync,
    input wire [1:0] cmd,
    input wire [2:0] index,
    input wire [3:0] data,
    output wire [3:0] q0,
    output wire [3:0] q1,
    output wire [3:0] q2,
    output wire [3:0] q3,
    output wire [3:0] q4,
    output wire [3:0] q
);

    wire c0 = cmd[0];
    wire c1 = cmd[1];

    wire not_c1;
    not(not_c1, c1);

    wire X;
    and(X, not_c1, c0);
    
    wire SYNC;
    and(SYNC, X, sync);

    wire [7:0] sync_extend;
    assign sync_extend[0] = SYNC;
    assign sync_extend[1] = SYNC;
    assign sync_extend[2] = SYNC;
    assign sync_extend[3] = SYNC;
    assign sync_extend[4] = SYNC;
    assign sync_extend[5] = SYNC;
    assign sync_extend[6] = SYNC;
    assign sync_extend[7] = SYNC;

    wire [7:0] idx_dec_8;

    dec_3_8 dec_3_8_1(
        .a(index),
        .q(idx_dec_8)
    );


    wire [7:0] data_sync;
    and(data_sync[0], sync_extend[0], idx_dec_8[0]);
    and(data_sync[1], sync_extend[1], idx_dec_8[1]);
    and(data_sync[2], sync_extend[2], idx_dec_8[2]);
    and(data_sync[3], sync_extend[3], idx_dec_8[3]);
    and(data_sync[4], sync_extend[4], idx_dec_8[4]);
    and(data_sync[5], sync_extend[5], idx_dec_8[5]);
    and(data_sync[6], sync_extend[6], idx_dec_8[6]);
    and(data_sync[7], sync_extend[7], idx_dec_8[7]);

    d_4_bits_trigger trigger0 (
        .reset(reset),
        .sync(data_sync[0]),
        .d(data),
        .q(q0)
    );


    d_4_bits_trigger trigger1 (
        .reset(reset),
        .sync(data_sync[1]),
        .d(data),
        .q(q1)
    );


    d_4_bits_trigger trigger2 (
        .reset(reset),
        .sync(data_sync[2]),
        .d(data),
        .q(q2)
    );

    d_4_bits_trigger trigger3 (
        .reset(reset),
        .sync(data_sync[3]),
        .d(data),
        .q(q3)
    );

    d_4_bits_trigger trigger4 (
        .reset(reset),
        .sync(data_sync[4]),
        .d(data),
        .q(q4)
    );

    wire [3:0] extend_idx_0 = {idx_dec_8[0], idx_dec_8[0], idx_dec_8[0], idx_dec_8[0]};
    wire [3:0] extend_idx_1 = {idx_dec_8[1], idx_dec_8[1], idx_dec_8[1], idx_dec_8[1]};
    wire [3:0] extend_idx_2 = {idx_dec_8[2], idx_dec_8[2], idx_dec_8[2], idx_dec_8[2]};
    wire [3:0] extend_idx_3 = {idx_dec_8[3], idx_dec_8[3], idx_dec_8[3], idx_dec_8[3]};
    wire [3:0] extend_idx_4 = {idx_dec_8[4], idx_dec_8[4], idx_dec_8[4], idx_dec_8[4]};

    wire [3:0] Q0;
    and4 a04(
        .a(q0),
        .b(extend_idx_0),
        .q(Q0)
    );
    wire [3:0] Q1;
    and4 a14(
        .a(q1),
        .b(extend_idx_1),
        .q(Q1)
    );
    wire [3:0] Q2;
    and4 a24(
        .a(q2),
        .b(extend_idx_2),
        .q(Q2)
    );
    wire [3:0] Q3;
    and4 a34(
        .a(q3),
        .b(extend_idx_3),
        .q(Q3)
    );
    wire [3:0] Q4;
    and4 a44(
        .a(q4),
        .b(extend_idx_4),
        .q(Q4)
    );

    wire [3:0] or_0_1;
    or4 o1(.q(or_0_1), .a(Q0), .b(Q1));
    wire [3:0] or_2_3;
    or4 o2(.q(or_2_3), .a(Q2), .b(Q3));
    wire [3:0] or_2_3_4;
    or4 o3(.q(or_2_3_4), .a(or_2_3), .b(Q4));
    or4 o4(.q(q), .a(or_0_1), .b(or_2_3_4));

endmodule


module neg_4_bits(
    input wire [3:0] a,
    output wire [3:0] q
);
    wire [3:0] not_a;
    not(not_a[0], a[0]);
    not(not_a[1], a[1]);
    not(not_a[2], a[2]);
    not(not_a[3], a[3]);

    wire [3:0] const_1 = 4'b0001;

    wire [4:0] extend_q;

    four_bit_adder plus(
        .a(not_a),
        .b(const_1),
        .s(extend_q)
    );

    assign q = extend_q[3:0];

endmodule


module neg_mod_5(
    input wire [2:0] a,
    output wire [2:0] q
);

    wire [3:0] extend_a;
    assign extend_a[2:0] = a;
    assign extend_a[3] = 1'b0;

    wire [2:0] a_mod_5;

    mod5 m5(
        .a(extend_a),
        .q(a_mod_5)
    );

    wire [3:0] extend_a_mod_5;
    assign extend_a_mod_5[2:0] = a_mod_5;
    assign extend_a_mod_5[3] = 1'b0;


    wire [3:0] neg_a_mod_5;
    neg_4_bits n4b(
        .a(extend_a_mod_5),
        .q(neg_a_mod_5)
    );

    wire [3:0] const_5 = 4'b0101;

    wire [4:0] extend_q;
    
    four_bit_adder p4b (
        .a(const_5),
        .b(neg_a_mod_5),
        .s(extend_q)
    );

    assign q = extend_q[2:0];

endmodule


module inout_cmd (
    input wire [1:0] cmd,
    input wire [3:0] pout,
    output wire [3:0] inpout
);

    wire c = cmd[1];
    wire not_c;
    not(not_c, c);

    nmos(inpout[0], pout[0], c);
    nmos(inpout[1], pout[1], c);
    nmos(inpout[2], pout[2], c);
    nmos(inpout[3], pout[3], c);

    pmos(inpout[0], pout[0], not_c);
    pmos(inpout[1], pout[1], not_c);
    pmos(inpout[2], pout[2], not_c);
    pmos(inpout[3], pout[3], not_c);

endmodule



module shift_index (
    input wire [1:0] cmd,
    input wire sync,
    input wire [2:0] curr_index,
    input wire [2:0] index,
    output wire [2:0] q
);
    wire c0 = cmd[0];
    wire c1 = cmd[1];

    wire c0_c1_and;
    and(c0_c1_and, c0, c1);

    wire c0_c1_xor;
    xor(c0_c1_xor, c0, c1);

    wire [1:0] cmd_to_next_idx;

    and(cmd_to_next_idx[0], c1, c0_c1_xor);
    assign cmd_to_next_idx[1] = 0;

    wire [2:0] next_idx;

    next_index ni(
        .cmd(cmd_to_next_idx),
        .sync(sync),
        .index(curr_index),
        .next_idx(next_idx)
    );

    wire sync_cmd_and;
    and(sync_cmd_and, c0_c1_and, sync);

    wire [2:0] extend_sync_cmd_and = {sync_cmd_and, sync_cmd_and, sync_cmd_and};

    wire [2:0] idx;

    neg_mod_5 nm5(
        .a(index),
        .q(idx)
    );

    wire [2:0] shift_idx;

    and(shift_idx[0], idx[0], extend_sync_cmd_and[0]);
    and(shift_idx[1], idx[1], extend_sync_cmd_and[1]);
    and(shift_idx[2], idx[2], extend_sync_cmd_and[2]);

    wire [3:0] sum;

    three_bit_adder tba(
        .a(next_idx),
        .b(shift_idx),
        .s(sum)
    );

    mod5 m5(
        .a(sum),
        .q(q)
    );


    
endmodule


module stack_structural_normal (
    input wire RESET,
    input wire [1:0] COMMAND,
    input wire CLK,
    input wire [2:0] INDEX,
    input wire [3:0] IO_DATA,
    output wire [3:0] d0,
    output wire [3:0] d1,
    output wire [3:0] d2,
    output wire [3:0] d3,
    output wire [3:0] d4
);
    wire reset = RESET;
    wire sync = CLK;
    wire [2:0] index = INDEX;
    wire [3:0] data = IO_DATA;
    wire [1:0] cmd = COMMAND;
    wire [3:0] slow_data;

    d_4_bits_trigger d_4_trigger (
        .reset(reset),
        .sync(sync),
        .d(IO_DATA),
        .q(slow_data)
    );

    wire [1:0] slow_cmd;

    d_2_bits_trigger d_2_trigger (
        .reset(reset),
        .sync(sync),
        .d(cmd),
        .q(slow_cmd)
    );

    wire [2:0] idx;
    current_index curr_idx (
        .reset(reset),
        .cmd(slow_cmd),
        .sync(sync),
        .q(idx)
    );

    wire [2:0] idx_with_shift;

    shift_index shift_idx(
        .cmd(slow_cmd),
        .sync(sync),
        .curr_index(idx),
        .index(index),
        .q(idx_with_shift)
    );

    wire [2:0] idx_to_mem;

    d_3_bits_trigger d_3_trigger(
        .reset(reset),
        .sync(sync),
        .d(idx_with_shift),
        .q(idx_to_mem)
    );

    wire not_sync;
    not(not_sync, sync);

    wire [3:0] mem_d;

    memory mem(
        .reset(reset),
        .sync(not_sync),
        .cmd(slow_cmd),
        .index(idx_to_mem),
        .data(slow_data),
        .q0(d4),
        .q1(d0),
        .q2(d1),
        .q3(d2),
        .q4(d3),
        .q(mem_d)
    );

    wire [1:0] cmd_and_sync;
    and(cmd_and_sync[0], slow_cmd[0], sync);
    and(cmd_and_sync[1], slow_cmd[1], sync);

    inout_cmd ino_cmd (
        .cmd(cmd_and_sync),
        .pout(mem_d),
        .inpout(IO_DATA)
    );
endmodule
