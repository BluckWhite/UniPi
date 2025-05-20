module ABC (
    soc, eocx, eocy, x, y,
    dav_, rfd, q,
    reset_, clock
);
    input eocx, eocy, rfd;
    input[7:0] x, y;
    input reset_, clock;

    output soc, dav_;
    output[31:0] q;

    wire b2, b1, b0, c1, c0;

    PARTE_OPERATIVA PO(soc, eocx, eocy, x, y,
                       dav_, rfd, q,
                       reset_, clock,
                       b2, b1, b0, c1, c0);
    PARTE_CONTROLLO PC(reset_, clock,
                       b2, b1, b0, c1, c0);

endmodule

module PARTE_OPERATIVA (
    soc, eocx, eocy, x, y,
    dav_, rfd, q,
    reset_, clock,
    b2, b1, b0, c1, c0
);
    input eocx, eocy, rfd;
    input[7:0] x, y;
    input reset_, clock;

    output soc, dav_;
    output[31:0] q;

    reg SOC; assign soc = SOC;
    reg DAV; assign dav_ = DAV;
    reg[31:0] Q; assign q = Q;
    
    wire[17:0] ris;
    QUADRATO_DELLA_SOMMA QS(x, y, ris);

    input b2, b1, b0;
    output c1, c0;
    assign c1 = ~rfd, c0 = ~eocx & ~eocy;

    always @(reset_ == 0) SOC <= 0;
    always @(posedge clock) if (reset_ == 1) begin
        casex ({b1,b0})
            2'b00 : SOC <= 1;
            2'b01 : SOC <= 0;
            2'b11 : SOC <= SOC;
        endcase
    end

    always @(reset_ == 0) DAV <= 1;
    always @(posedge clock) if (reset_ == 1) begin
        casex ({b2,b1})
            2'b00 : DAV <= DAV;
            2'b01 : DAV <= 0;
            2'b11 : DAV <= 1;
        endcase
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex (b0)
            1'b0 : Q <= Q;
            1'b1 : Q <= {14'b0, ris};
        endcase
    end
endmodule

module PARTE_CONTROLLO (
    reset_, clock,
    b2, b1, b0, c1, c0
);
    input reset_, clock;
    input c1, c0;
    output b2, b1, b0;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    assign {b2,b1,b0} = (STAR == S0) ? 3'b000 :
                        (STAR == S1) ? 3'b001 :
                        (STAR == S2) ? 3'b010 :
                       /*STAR == S3*/  3'b110;

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: STAR <= c0 ? S1 : S0;
            S1: STAR <= c0 ? S1 : S2;
            S2: STAR <= c1 ? S3 : S2;
            S3: STAR <= c1 ? S3 : S0;
        endcase
    end

endmodule

/*     u-addr  | u-codice  | u-addr T  | u-addr F
    (S0)  00   |    000    |    01     |    00
    (S1)  01   |    001    |    01     |    10
    (S2)  10   |    010    |    11     |    10
    (S3)  11   |    110    |    11     |    00
*/

module QUADRATO_DELLA_SOMMA (
    x, y, ris
);
    input[7:0] x, y;
    output[17:0] ris;

    wire[15:0] x_sqr, y_sqr, xy;
    mul_add_nat MUL_1(.x(x), .y(x), .c(8'b0), .m(x_sqr));
    mul_add_nat MUL_2(.x(y), .y(y), .c(8'b0), .m(y_sqr));
    mul_add_nat MUL_3(.x(x), .y(y), .c(8'b0), .m(xy));

    wire[16:0] sum_1;
    add #(.N(16)) ADDER_1(.x(x_sqr), .y(y_sqr), .c_in(1'b0), .s(sum_1[15:0]), .c_out(sum_1[16]));
    add #(.N(17)) ADDER_2(.x(sum_1), .y({xy[15:0], 1'b0}), .c_in(1'b0), .s(ris[16:0]), .c_out(ris[17]));

endmodule