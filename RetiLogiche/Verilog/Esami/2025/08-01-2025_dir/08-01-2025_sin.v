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

    //wire
//    Parte_Operativa PO(soc1,)

endmodule

module Parte_Operativa ( soc1, eoc1, x1,
            soc2, eoc2, x2,
            soc3, eoc3, x3,
            dav_, rfd, result,
            clock, reset_,
            b0, b1, b2, c0, c1, c2, c3);

    
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

    input b0, b1, b2;

    output c0, c1, c2, c3;
    assign  c0 = ~eoc1 & ~eoc2 & ~eoc3,
            c1 = eoc1 & eco2 & eoc3,
            c2 = ~rfd,
            c3 = 1;


    always @(reset_ == 0) begin SOC <= 0 end
    always @(posedge clock) if (reset_ == 1) begin
        casex({b1,b0})
            2'B00 : SOC <= 1;
            2'B01 : SOC <= 0;
            2'B10 : SOC <= SOC;
        endcase
    end
    
    always @(reset_ == 0) begin DAV_ <= 1 end
    always @(posedge clock) if (reset_ == 1) begin
        casex({b2, b0})
            2'B00 : DAV_ <= DAV_;
            2'B01 : DAV_ <= 0;
            2'B11 : DAV_ <= 1;
        endcase
    end

    always @(reset_ == 0) begin RESULT <= 0 end
    always @(posedge clock) if (reset_ == 1) begin
        casex(b3)
            'B0 : RESULT <= RESULT;
            'B1 : RESULT <= {3'B000, expr};         
        endcase
    end

endmodule

module Parte_Controllo(b2, b1, b0, c0, clock, reset_);
    input clock, reset_;
    input c0;
    output b2, b1, b0;

    reg [1:0] STAR; parameter S0 = 'B00, S1 = 'B01, S2 = 'B10, S3 = 'B11;

    // assign b2 =

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) begin
        casex(STAR)
            S0: STAR <= (c0 == 1) ? S1 : S0;
            S1: STAR <= (c1 == 1) ? S2 : S1;
            S2: STAR <= (c2 == 1) ? S3 : S2;
            S3: STAR <= S0;
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