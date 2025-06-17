// --- Nicholas Del Buono - S - M: 673120
module ABC (
    soc_x, soc_y, eoc_x, eoc_y,
    x, y, dav_, rfd, z,
    reset_, clock
);
    input eoc_x, eoc_y, rfd;
    input[7:0] x, y;
    input reset_, clock;
    output z, dav_, soc_x, soc_y;

    wire b2, b1, b0, c2, c1, c0;

    PARTE_OPERATIVA PO( soc_x, soc_y, eoc_x, eoc_y,
    x, y, dav_, rfd, z,
    reset_, clock,
    b2, b1, b0, c2, c1, c0);

    PARTE_CONTROLLO PC(reset_, clock,
    b2, b1, b0, c2, c1, c0);

endmodule

module PARTE_OPERATIVA (
    soc_x, soc_y, eoc_x, eoc_y,
    x, y, dav_, rfd, z,
    reset_, clock,
    b2, b1, b0, c2, c1, c0
);    
    input eoc_x, eoc_y, rfd;
    input[7:0] x, y;
    input reset_, clock;
    output z, dav_, soc_x, soc_y;
    
    wire isArea;
    IN_AREA isIn(x, y, isArea);

    reg SOC, DAV_, RESULT; 
    assign soc_x = SOC, soc_y = SOC, dav_ = DAV_;
    assign z = RESULT;

    input b2, b1, b0;
    output c2, c1, c0;

    assign c0 = ~eoc_x & ~eoc_y,
           c1 = eoc_x & eoc_y,
           c2 = rfd;

    always @(reset_ == 0) #1 SOC <= 0;
    always @(posedge clock) if(reset_ == 1) #3
        casex ({b1,b0})
            2'b00: SOC <= 1;
            2'b01: SOC <= 0;
            2'b10: SOC <= SOC;
        endcase

    always @(reset_ == 0) #1 DAV_ <= 1;
    always @(posedge clock) if(reset_ == 1) #3
        casex ({b2,b1})
            2'b00: DAV_ <= DAV_;
            2'b01: DAV_ <= 0;
            2'b11: DAV_ <= 1;
        endcase

    always @(posedge clock) if(reset_ == 1) #3
        casex (b0)
            1'b0: RESULT <= RESULT;
            1'b1: RESULT <= isArea;
        endcase
endmodule

module PARTE_CONTROLLO (
    reset_, clock,
    b2, b1, b0, c2, c1, c0
);
    input reset_, clock;
    output b2, b1, b0;
    input c2, c1, c0;    
    
    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    assign {b2, b1, b0} = (STAR == S0) ? 3'b000 :
                          (STAR == S1) ? 3'b001 :
                          (STAR == S2) ? 3'b010 :
                        /*(STAR == S3)*/ 3'b110;

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if(reset_ == 1) #3
        casex (STAR)
            S0: STAR <= c0 ? S1 : S0;
            S1: STAR <= c1 ? S2 : S1;
            S2: STAR <= c2 ? S2 : S3;
            S3: STAR <= c2 ? S0 : S3; 
        endcase

endmodule


module IN_AREA (
    x, y, z
);
    input[7:0] x, y;
    output z;

    wire[7:0] ab_x, ab_y;

    abs ABS_x(.x(x), .abs_x(ab_x));
    abs ABS_y(.x(y), .abs_x(ab_y));
    
    wire[8:0] ab_xy;
    add #(.N(8)) ADDER(.x(ab_x), .y(ab_y), .c_in(1'b0), .s(ab_xy[7:0]), .c_out(ab_xy[8]));

    wire inF1, inF1_border;
    comp_nat #(.N(9)) FIG1(.a(ab_xy), .b(9'd64), .min(inF1), .eq(inF1_border));

    wire inF2_x, inF2_x_border;
    comp_nat #(.N(8)) FIG2_1(.a(ab_x), .b(8'd48), .min(inF2_x), .eq(inF2_x_border));

    wire inF2_y, inF2_y_border;
    comp_nat #(.N(8)) FIG2_2(.a(ab_y), .b(8'd48), .min(inF2_y), .eq(inF2_y_border));

    wire test_F1; 
    assign test_F1 = inF1 | inF1_border;
    
    wire test_F2; 
    assign test_F2 = (inF2_x | inF2_x_border) & (inF2_y | inF2_y_border);

    assign z = test_F1 ^ test_F2;

endmodule


/*
    u-addr | u-code | ceff | u-addr T | u-addr F
(S0)  00   |  000   |  00  |    01    |   00
(S1)  01   |  001   |  01  |    10    |   01
(S2)  10   |  010   |  10  |    10    |   11
(S3)  11   |  110   |  10  |    00    |   11
*/


// fine file