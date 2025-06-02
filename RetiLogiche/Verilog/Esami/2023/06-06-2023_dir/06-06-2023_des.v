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

    reg SOC; assign soc_x = SOC, soc_y = SOC;
    reg DAV_, Z; assign dav_ = DAV_, z = Z;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    wire isArea;
    IN_AREA isInArea(.x(x), .y(y), .isArea(isArea));

    always @(reset_ == 0) #1 begin
        STAR <= S0;
        SOC <= 0;
        DAV_ <= 1;
    end
    always @(posedge clock) if(reset_ == 1) #3
        casex (STAR)
            S0: begin
                SOC <= 1;
                STAR <= ({eoc_x, eoc_y} == 2'b00) ? S1 : S0;
            end
            S1: begin
                Z <= isArea;
                SOC <= 0;
                STAR <= ({eoc_x, eoc_y} == 2'b11) ? S2 : S1;       
            end
            S2: begin
                DAV_ <= 0;
                STAR <= rfd ? S2 : S3;  
            end
            S3: begin
                DAV_ <= 1;
                STAR <= rfd ? S0 : S3;
            end
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