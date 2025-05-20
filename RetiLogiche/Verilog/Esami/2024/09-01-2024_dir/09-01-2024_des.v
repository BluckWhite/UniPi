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

    reg SOC; assign soc = SOC;
    reg DAV; assign dav_ = DAV;
    reg[31:0] Q; assign q = Q;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    wire[17:0] ris;
    QUADRATO_DELLA_SOMMA QS(x, y, ris);

    always @(reset_ == 0) begin
        STAR <= S0;
        SOC <= 0;
        DAV <= 1;
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                SOC <= 1;
                STAR <= ({eocx, eocy}) == 2'b00 ? S1 : S0;
            end
            S1: begin
                SOC <= 0;
                Q <= {14'b0, ris};
                STAR <= ({eocx, eocy}) == 2'b00 ? S1 : S2;
            end
            S2: begin
                DAV <= 0;
                STAR <= (rfd == 0) ? S3 : S2;
            end
            S3: begin
                DAV <= 1;
                STAR <= (rfd == 0) ? S3 : S0;
            end
        endcase
    end

endmodule

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