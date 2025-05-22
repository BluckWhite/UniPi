module ABC (
    x, y,
    soc, eoc, out,
    reset_, clock
);
    input clock, reset_;
    input soc;
    output eoc;
    input[7:0] y;
    output[7:0] x;
    output[15:0] out;

    wire b1, b0, c1, c0;

    PARTE_OPERATIVA PO(x, y,
                       soc, eoc, out,
                       reset_, clock,
                       b1, b0, c1, c0);
    PARTE_CONTROLLO PC(reset_, clock,
                       b1, b0, c1, c0);

endmodule

module PARTE_OPERATIVA (
    x, y,
    soc, eoc, out,
    reset_, clock,
    b1, b0, c1, c0
);
    input clock, reset_;
    input soc;
    output eoc;
    input[7:0] y;
    output[7:0] x;
    output[15:0] out;

    reg EOC; assign eoc = EOC;
    reg[7:0] X; assign x = X;
    reg[15:0] OUT; assign out = OUT;

    CHECK CK(X, y, ris);

    input b1, b0; output c1, c0;
    assign c1 = ris, c0 = soc;

    always @(reset_ == 0) EOC <= 1;
    always @(posedge clock) if(reset_ == 1) begin
        casex ({b1,b0})
            2'b00: EOC <= 1;
            2'b01: EOC <= 0;
            2'b10: EOC <= EOC;
        endcase
    end

    always @(reset_ == 0) X <= 0;
    always @(posedge clock) if(reset_ == 1) begin
        casex(b0)
            1'b0: X <= X;
            1'b1: X <= X + 1;
        endcase
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(b0)
            1'b0: OUT <= OUT;
            1'b1: OUT <= {X,y};
        endcase
    end

endmodule

module PARTE_CONTROLLO (
    reset_, clock,
    b1, b0, c1, c0
);
    input reset_, clock;
    input c1, c0;
    output b1, b0;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2;

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: STAR <= c0 ? S1 : S0;
            S1: STAR <= c1 ? S2 : S1;
            S2: STAR <= c0 ? S2 : S0;
        endcase
    end

    assign {b1, b0} = (STAR == S0) ? 2'b00 :
                      (STAR == S1) ? 2'b01 :
                    /*(STAR == S2)*/ 2'b10;

endmodule

module CHECK (
    x, y, ris
);
    input[7:0] x, y;
    output ris;

    wire[15:0] w1;
    mul_add_nat #(.N(8), .M(8)) MUL(.x(x), .y(y), .c(8'b0), .m(w1));

    comp_nat #(.N(16)) CMP(.a(16'HABB9), .b(w1), .min(ris));

endmodule