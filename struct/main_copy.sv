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
    output wire q,
    output wire neg_q
);
    wire not_d;
    
    not(not_d, d);

    sync_rs_trigger sync_inst (.r(not_d), .sync(sync), .s(d), .q(q), .neg_q(neg_q));

    // always @(*) $display("d %0t \t S: %d \t Q: %d \t D: ", $time, sync, q, d);

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
    // and(new_d, extend_reset, d);
    assign new_d = d & extend_reset;

    d_trigger d0 (.d(new_d[0]), .sync(new_sync), .q(q[0]), .neg_q());
    
    d_trigger d1 (.d(new_d[1]), .sync(new_sync), .q(q[1]), .neg_q());
    
    d_trigger d2 (.d(new_d[2]), .sync(new_sync), .q(q[2]), .neg_q());

    d_trigger d3 (.d(new_d[3]), .sync(new_sync), .q(q[3]), .neg_q());

    // always @(*) $display("d_4_bits %0t \t S: %d \t Q: %d \t D: ", $time, sync, q, d);

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

    wire not_in0;
    wire not_in1;
    wire not_in2;
    not(not_in0, a[0]);
    not(not_in1, a[1]);
    not(not_in2, a[2]);

    and(q[0], not_in0, not_in1, not_in2);

    and(q[1], a[0], not_in1, not_in2);

    and(q[2], not_in0, a[1], not_in2);

    and(q[3], a[0], a[1], not_in2);

    and(q[4], not_in0, not_in01, a[2]);

    and(q[5], a[0], not_in01, a[2]);

    and(q[6], not_in0, a[1], a[2]);

    and(q[7], a[0], a[1], a[2]);

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

// module mod5 (
//     input wire [3:0] a,
//     output wire [2:0] q
// );





// endmodule

module mod5 (
    input wire [3:0] a,   // 4-битный вход
    output reg [2:0] q    // 3-битный выход
);
    always @(*) begin
        case (a)
            4'b0000: q = 3'b000; // 0 % 5 = 0
            4'b0001: q = 3'b001; // 1 % 5 = 1
            4'b0010: q = 3'b010; // 2 % 5 = 2
            4'b0011: q = 3'b011; // 3 % 5 = 3
            4'b0100: q = 3'b100; // 4 % 5 = 4
            4'b0101: q = 3'b000; // 5 % 5 = 0
            4'b0110: q = 3'b001; // 6 % 5 = 1
            4'b0111: q = 3'b010; // 7 % 5 = 2
            4'b1000: q = 3'b011; // 8 % 5 = 3
            4'b1001: q = 3'b100; // 9 % 5 = 4
            4'b1010: q = 3'b000; // 5 % 5 = 0
            4'b1011: q = 3'b001; // 6 % 5 = 1
            4'b1100: q = 3'b010; // 7 % 5 = 2
            4'b1101: q = 3'b011; // 8 % 5 = 3
            4'b1110: q = 3'b100; // 9 % 5 = 4
            4'b1111: q = 3'b000; // 9 % 5 = 0
        endcase
    end

    // always @(*) $display("%0t \t %d \t %d", $time, a, q);


endmodule


module next_index (
    input wire [1:0] cmd,
    input wire sync,
    input wire [2:0] index,
    output wire [2:0] next_idx
);
    wire c0 = cmd[0];
    wire c1 = cmd[1];

    always @(*) $display("mod %0t \t %d \t %d \t %d", $time, c0, c1, cmd);

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

    // always @(*) $display("%0t \t %d \t %d \t %d \t %d \t %d \t %d", $time, reset, sync, trigger1_out, trigger2_out, next_idx, cmd);
    
endmodule




// module memory (
//     input wire reset,
//     input wire sync,
//     input wire [1:0] cmd,
//     input wire [2:0] index,
//     input wire [3:0] data,
//     output wire [3:0] q0,
//     output wire [3:0] q1,
//     output wire [3:0] q2,
//     output wire [3:0] q3,
//     output wire [3:0] q4,
//     output wire [3:0] q
// );

//     wire SYNC;
//     wire c0 = cmd[0];
//     wire c1 = cmd[1];

//     wire not_c1;

//     not(not_c1, c1);

//     wire X;

//     and(X, not_c1, c0);
//     and(SYNC, X, sync);

//     wire [7:0] sync_extend = {SYNC, SYNC, SYNC, SYNC, SYNC, SYNC, SYNC, SYNC};

//     wire [7:0] idx_dec_8;

//     dec_3_8 dec_3_8_1(
//         .a(index),
//         .q(idx_dec_8)
//     );

//     wire [7:0] data_sync;
//     // and(data_sync, sync_extend, idx_dec_8);
//     assign data_sync = sync_extend & idx_dec_8;


//     wire [3:0] data_0;

//     d_4_bits_trigger trigger0 (
//         .reset(reset),
//         .sync(data_sync[0]),
//         .d(data),
//         .q(data_0)
//     );


//     wire [3:0] data_1;

//     d_4_bits_trigger trigger1 (
//         .reset(reset),
//         .sync(data_sync[1]),
//         .d(data),
//         .q(data_1)
//     );


//     wire [3:0] data_2;

//     d_4_bits_trigger trigger2 (
//         .reset(reset),
//         .sync(data_sync[2]),
//         .d(data),
//         .q(data_2)
//     );


//     wire [3:0] data_3;

//     d_4_bits_trigger trigger3 (
//         .reset(reset),
//         .sync(data_sync[3]),
//         .d(data),
//         .q(data_3)
//     );


//     wire [3:0] data_4;

//     d_4_bits_trigger trigger4 (
//         .reset(reset),
//         .sync(data_sync[4]),
//         .d(data),
//         .q(data_4)
//     );


//     assign q0 = data_0;
//     assign q1 = data_1;
//     assign q2 = data_2;
//     assign q3 = data_3;
//     assign q4 = data_4;

//     wire [3:0] extend_idx_0 = {idx_dec_8[0], idx_dec_8[0], idx_dec_8[0], idx_dec_8[0]};
//     wire [3:0] extend_idx_1 = {idx_dec_8[1], idx_dec_8[1], idx_dec_8[1], idx_dec_8[1]};
//     wire [3:0] extend_idx_2 = {idx_dec_8[2], idx_dec_8[2], idx_dec_8[2], idx_dec_8[2]};
//     wire [3:0] extend_idx_3 = {idx_dec_8[3], idx_dec_8[3], idx_dec_8[3], idx_dec_8[3]};
//     wire [3:0] extend_idx_4 = {idx_dec_8[4], idx_dec_8[4], idx_dec_8[4], idx_dec_8[4]};

//     wire Q0; and(Q0, data_0, extend_idx_0);
//     wire Q1; and(Q1, data_1, extend_idx_1);
//     wire Q2; and(Q2, data_2, extend_idx_2);
//     wire Q3; and(Q3, data_3, extend_idx_3);
//     wire Q4; and(Q4, data_4, extend_idx_4);

//     assign q = Q0 | Q1 | Q2 | Q3 | Q4;
    
//     // initial begin
//     //     $display("time \t sync \t reset \t q0 \t q1 \t q2 \t q3 \t q4 \t q");
//     // end
//     // always @(*) $display("%0t  \t %b   \t %b    \t %d \t %d \t %d \t %d \t %d \t %d", $time, sync, reset, q0, q1, q2, q3, q4, q);

// endmodule

// module shift_index (
//     input wire [1:0] cmd,
//     input wire sync,
//     input wire [2:0] curr_index,
//     input wire [2:0] index,
//     output wire [2:0] q
// );
//     wire c0 = cmd[0];
//     wire c1 = cmd[1];

//     wire c0_c1_and;
//     and(c0_c1_and, c0, c1);

//     wire c0_c1_xor;
//     xor(c0_c1_xor, c0, c1);

//     wire [1:0] cmd_to_next_idx = 2'b00;

//     and(cmd_to_next_idx[0], c1, c0_c1_xor);

//     wire [2:0] next_idx;

//     next_index ni(
//         .cmd(cmd_to_next_idx),
//         .sync(sync),
//         .index(curr_index),
//         .next_idx(next_idx)
//     );

//     wire sync_cmd_and;
//     and(sync_cmd_and, c0, c1, sync);

//     wire [2:0] extend_sync_cmd_and = {sync_cmd_and, sync_cmd_and, sync_cmd_and};

//     wire [2:0] shift_idx;
//     assign shift_idx = index & extend_sync_cmd_and;

//     wire [3:0] sum;

//     three_bit_adder tba(
//         .a(next_idx),
//         .b(shift_idx),
//         .s(sum)
//     );

//     mod5 m5(
//         .a(sum),
//         .q(q)
//     );

    
// endmodule

module slow (
    input wire a,
    output wire q
);
    wire a00, a01, a02, a03, a04, a05, a06, a07, a08;
    wire a10, a11, a12, a13, a14, a15, a16, a17, a18;
    wire a20, a21, a22, a23, a24, a25, a26, a27, a28;
    wire a30, a31, a32, a33, a34, a35, a36, a37, a38;
    wire a40, a41, a42, a43, a44, a45, a46, a47, a48;
    not(a00, a);
    not(a01, a00);
    not(a02, a01);
    not(a03, a02);
    not(a04, a03);
    not(a05, a04);
    not(a06, a05);
    not(a07, a06);
    not(a08, a07);
    not(a10, a08);
    not(a11, a10);
    not(a12, a11);
    not(a13, a12);
    not(a14, a13);
    not(a15, a14);
    not(a16, a15);
    not(a17, a16);
    not(a18, a17);
    not(a20, a18);
    not(a21, a20);
    not(a22, a21);
    not(a23, a22);
    not(a24, a23);
    not(a25, a24);
    not(a26, a25);
    not(a27, a26);
    not(a28, a27);
    not(a30, a28);
    not(a31, a30);
    not(a32, a31);
    not(a33, a32);
    not(a34, a33);
    not(a35, a34);
    not(a36, a35);
    not(a37, a36);
    not(a38, a37);
    not(a40, a38);
    not(a41, a40);
    not(a42, a41);
    not(a43, a42);
    not(a44, a43);
    not(a45, a44);
    not(a46, a45);
    not(a47, a46);
    not(a48, a47);
    not(q, a48);

endmodule


// module my_stack (
//     input wire reset,
//     input wire [1:0] cmd,
//     input wire sync,
//     input wire [2:0] index,
//     input wire [3:0] data,
//     output wire [3:0] d0,
//     output wire [3:0] d1,
//     output wire [3:0] d2,
//     output wire [3:0] d3,
//     output wire [3:0] d4,
//     output wire [3:0] d
// );

//     wire [2:0] idx;
//     current_index curr_idx(
//         .reset(reset),
//         .cmd(cmd),
//         .sync(sync),
//         .q(idx)
//     );

//     wire [2:0] idx_with_shift;

//     shift_index shift_idx(
//         .cmd(cmd),
//         .sync(sync),
//         .curr_index(idx),
//         .index(index),
//         .q(idx_with_shift)
//     );

//     wire [2:0] idx_to_mem;

//     d_3_bits_trigger d_3_trigger(
//         .reset(reset),
//         .sync(sync),
//         .d(idx_with_shift),
//         .q(idx_to_mem)
//     );

//     wire slow_sync;

//     slow slow_s(
//         .a(sync),
//         .q(slow_s)
//     );

//     memory mem(
//         .reset(reset),
//         .sync(slow_sync),
//         .cmd(cmd),
//         .index(idx_to_mem),
//         .data(data),
//         .q0(d0),
//         .q1(d1),
//         .q2(d2),
//         .q3(d3),
//         .q4(d4),
//         .q(d)
//     );
// endmodule



module main;
    reg [1:0] cmd = 2'b00;
    reg sync = 1'b0;
    reg [2:0] index = 3'b000;
    wire [2:0] next_idx;


    next_index ni (
        .cmd(cmd),
        .sync(sync),
        .index(index),
        .next_idx(next_idx)
    );

    initial begin
        #100; sync = 1'b1;
        #100; sync = 1'b0;
        #100; sync = 1'b1;
        #100; sync = 1'b0;
    end
    initial begin
        $display("time \t sync \t cmd \t next_idx");
    end
    always @(*) $display("%0t \t %b \t %d \t %d", $time, sync, cmd, next_idx);

endmodule

