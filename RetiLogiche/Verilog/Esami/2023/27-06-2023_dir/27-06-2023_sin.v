module ABC (
    rfd_x, rfd_y, dav_x, dav_y,
    x, y, reset_, clock, out
);
    input dav_y, dav_x;
    output rfd_x, rfd_y;
    input[7:0] x, y;
    input reset_, clock;
    output out;

    wire b5, b3, b1, b0, c2, c1, c0;

    PARTE_OPERATIVA PO(rfd_x, rfd_y, dav_x, dav_y,
    x, y, reset_, clock, out,
    c2, c1, c0, b5, b3, b1, b0);
    PARTE_CONTROLLO PC(reset_, clock,
    c2, c1, c0, b5, b3, b1, b0);

endmodule

module PARTE_OPERATIVA (
    rfd_x, rfd_y, dav_x, dav_y,
    x, y, reset_, clock, out,
    c2, c1, c0, b5, b3, b1, b0
);
    input dav_y, dav_x;
    output rfd_x, rfd_y;
    input[7:0] x, y;
    input reset_, clock;
    output out;

    reg RFD; assign rfd_x = RFD, rfd_y = RFD;
    reg[7:0] COUNT;
    reg OUT; assign out = OUT;

    wire[7:0] max;
    MAX maxV(x, y, max);

    input b5, b3, b1, b0;
    output c2, c1, c0;
    assign  c2 = dav_x & dav_y,
            c1 = (COUNT == 1),
            c0 = ~dav_x & ~dav_y;

    always @(reset_ == 0) #1 RFD <= 1;
    always @(posedge clock) if (reset_ == 1) #3
        casex ({b1, b0})
            2'b00: RFD <= 1;
            2'b01: RFD <= 0;
            2'b10: RFD <= RFD;
        endcase
    
    always @(reset_ == 0) #1 OUT <= 0;
    always @(posedge clock) if (reset_ == 1) #3
        casex ({b3, b1})
            2'b00: OUT <= OUT;
            2'b01: OUT <= 1;
            2'b11: OUT <= 0;
        endcase
    
    always @(posedge clock) if (reset_ == 1) #3
        casex ({b5, b0})
            2'b00: COUNT <= COUNT;
            2'b01: COUNT <= max;
            2'b10: COUNT <= COUNT - 1;
        endcase
endmodule

module PARTE_CONTROLLO (
    reset_, clock,
    c2, c1, c0, b5, b3, b1, b0
);
    input reset_, clock;
    input c2, c1, c0;
    output b5, b3, b1, b0;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    assign {b5,b3,b1,b0} = (STAR == S0) ? 4'b0000 :
                           (STAR == S1) ? 4'b0001 :
                           (STAR == S2) ? 4'b1010 :
                         /*(STAR == S3)*/ 4'b0110;

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if(reset_ == 1) #3
        casex(STAR)
            S0: STAR <= c0 ? S1 : S0;
            S1: STAR <= S2;
            S2: STAR <= c1 ? S3 : S2;
            S3: STAR <= c2 ? S0 : S3;
        endcase
endmodule

module MAX (
    x, y, z
);
    input[7:0] x, y;
    output[7:0] z;

    wire w1;
    add #(.N(8)) ADDER(.x(x), .y(~y), .c_in(1'b1), .c_out(w1));
    
    assign z = w1 ? x : y;
endmodule