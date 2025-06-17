// --- Nicholas Del Buono - D - M: 673120
module ABC (
    soc_x, soc_y, eoc_x, eoc_y,
    x, y, dav_, rfd, z,
    reset_, clock
);
    input eoc_x, eoc_y, rfd;
    input[7:0] x, y;
    input reset_, clock;
    output z, dav_, soc_x, soc_y;

    reg SOC, DAV_, RESULT; 
    assign soc_x = SOC, soc_y = SOC, dav_ = DAV_;
    assign z = RESULT;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    wire isArea;
    IN_AREA isIn(x, y, isArea);

    always @(reset_ == 0) #1 begin
        STAR <= S0;
        DAV_ <= 1;
        SOC <= 0;
    end
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (STAR) 
            S0: begin
                SOC <= 1;
                STAR <= ({eoc_x, eoc_y} == 2'b00) ? S1 : S0;
            end
            S1: begin
                SOC <= 0;
                RESULT <= isArea;
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
    end

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
// fine file