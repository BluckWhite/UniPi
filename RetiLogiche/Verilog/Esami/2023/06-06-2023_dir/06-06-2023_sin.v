module ABC (
    soc_x, soc_y, eoc_x, eoc_y,
    x, y, 
    dav_, rfd, z,
    reset_, clock
);
    input eoc_x, eoc_y, rfd;
    output soc_x, soc_y, dav_, z;
    input[7:0] x, y;
    input reset_, clock;

    wire b3, b1, b0, c2, c1, c0;

    PARTE_OPERATIVA PO(soc_x, soc_y, eoc_x, eoc_y,
    x, y, 
    dav_, rfd, z,
    reset_, clock,
    b3, b1, b0, c2, c1, c0);

    PARTE_CONTROLLO PC(reset_, clock,
    b3, b1, b0, c2, c1, c0);

endmodule

module PARTE_OPERATIVA (
    soc_x, soc_y, eoc_x, eoc_y,
    x, y, 
    dav_, rfd, z,
    reset_, clock,
    b3, b1, b0, c2, c1, c0
);
    input eoc_x, eoc_y, rfd;
    output soc_x, soc_y, dav_, z;
    input[7:0] x, y;
    input reset_, clock;

    reg SOC; assign soc_x = SOC, soc_y = SOC;
    reg DAV_, Z; assign dav_ = DAV_, z = Z;

    input b3, b1, b0;
    output c2, c1, c0;
    assign  c0 = (~eoc_x & ~eoc_y),
            c1 = (eoc_x & eoc_y),
            c2 = rfd;


    wire isArea;
    IN_AREA isInArea(.x(x), .y(y), .isArea(isArea));

    always @(reset_ == 0) #1 SOC <= 0;
    always @(posedge clock) if(reset_ == 1) #3
        casex({b1,b0})
            2'b00: SOC <= 1;
            2'b01: SOC <= 0;
            2'b10: SOC <= SOC;
        endcase

    always @(reset_ == 0) #1 DAV_ <= 1;
    always @(posedge clock) if(reset_ == 1) #3
        casex({b3,b1})
            2'b00: DAV_ <= DAV_;
            2'b01: DAV_ <= 0;
            2'b11: DAV_ <= 1;
        endcase

    always @(posedge clock) if(reset_ == 1) #3
        casex({b0})
            1'b0: Z <= Z;
            1'b1: Z <= isArea;
        endcase

endmodule

module PARTE_CONTROLLO (
    reset_, clock,
    b3, b1, b0, c2, c1, c0
);
    input reset_, clock;
    output b3, b1, b0;
    input c2, c1, c0;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    assign {b3, b1, b0} = (STAR == S0) ? 3'b000 :
                          (STAR == S1) ? 3'b001 :
                          (STAR == S2) ? 3'b010 :
                        /*(STAR == S3)*/ 3'b110;

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if(reset_ == 1) #3
        casex(STAR)
            S0 : STAR <= c0 ? S1 : S0;
            S1 : STAR <= c1 ? S2 : S1;
            S2 : STAR <= c2 ? S2 : S3;
            S3 : STAR <= c2 ? S0 : S3;
        endcase

endmodule
    // X^2 + Y^2 < R^2
module IN_AREA (
    x, y, isArea
);
    input[7:0] x, y;
    output isArea;
    wire isLess, isEqual;

    wire[7:0] absX, absY;

    abs ABSX(.x(x), .abs_x(absX));
    abs ABSY(.x(y), .abs_x(absY));

    wire[15:0] x_2, y_2;
    wire[15:0] r; assign r = 'D4096;
    mul_add_nat #(.N(8), .M(8)) mul_x(.x(absX), .y(absX), .c(8'b0), .m(x_2));
    mul_add_nat #(.N(8), .M(8)) mul_y(.x(absY), .y(absY), .c(8'b0), .m(y_2));

    wire[15:0] xy;
    add #(.N(16)) adder(.x(x_2), .y(y_2), .c_in(1'b0), .s(xy));

    comp_nat #(.N(16)) cmp(.a(xy), .b(r), .min(isLess), .eq(isEqual));

    assign isArea = isLess ? 1 : isEqual;

endmodule

module abs (
    x, abs_x
);
    input[7:0] x;
    output[7:0] abs_x;

    wire[7:0] x_neg;
    add #(.N(8)) Adder_ABS(.x(~x), .y(8'b0), .c_in(1'b1), .s(x_neg));

    assign abs_x = x[7] ? x_neg : x;
endmodule

/*      u-addr | u-code | ceff | u-addr T | u-addr F
 (S0)   00         000     00       01         00
 (S1)   01         001     01       10         01
 (S2)   10         010     10       10         11
 (S3)   11         110     10       00         11
*/