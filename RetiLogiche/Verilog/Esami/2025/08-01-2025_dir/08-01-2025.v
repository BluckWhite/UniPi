module ABC( soc1, eoc1, x1,
            soc2, eoc2, x2,
            soc3, eoc3, x3,
            dav_, rfd, result,
            clock, reset_);

    input eoc1, eoc2, eoc3;
    input[7:0] x1, x2, x3;
    output soc1, soc2, soc3;

    input rfd; output dav_;
    output[15:0] result;

    input clock, reset_;

    reg SOC;
    reg DAV_;
    reg[15:0] RESULT;
    reg[1:0] STAR;

    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;
    assign soc1 = SOC, soc2 = SOC, soc3 = SOC;
    assign result = RESULT;
    assign dav_ = DAV_;

    wire[12:0] expr;
    EXPR e(x1, x2, x3, expr);

    always @(reset_ == 0) begin
            SOC <= 0;
            DAV_ <= 1;
            STAR <= S0;
            RESULT <= 0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: begin
                SOC <= 1;
                STAR <= ({eoc1, eoc2, eoc3} == 3'B000) ? S1 : S0;
            end
            S1: begin
                SOC <= 0;
                RESULT <= {3'B000, expr};
                STAR <= ({eoc1, eoc2, eoc3} == 3'B111) ? S2 : S1;
            end        
            S2: begin
                DAV_ <= 0;
                STAR <= (rfd == 0) ? S3 : S2;
            end
            S3: begin
                DAV_ <= 1;
                STAR <= S0;
            end
        endcase
    end
endmodule

module EXPR(x1, x2, x3, expr);

    // --- expr = 5*(x1 + 3*x2) + x3

    input[7:0] x1, x2, x3;
    output[12:0] expr;

    wire[9:0] rInter;
    mul_add_nat #(.N(8), .M(2)) mul_1(
        .x(x2), .y(2'B11), .c(x1),
        .m(rInter));
    mul_add_nat #(.N(10), .M(3)) mul_2(
        .x(rInter), .y(3'B101), .c({2'B00, x3}),
        .m(expr));

endmodule