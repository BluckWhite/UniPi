module ABC (
    soc, eoc, x, out,
    reset_, clock
);
    input eoc, reset_, clock;
    input[7:0] x;
    output out, soc;

    wire b8, b7, b6, b5, b4, b3, b2, b1, b0;
    wire c;
    wire[2:0] mjr;

    ParteOperativa PO(
        b8, b7, b6, b5, b4, b3, b2, b1, b0,
        c, mjr,
        soc, out, eoc, reset_, clock, x
    );
    ParteControllo PC(
        b8, b7, b6, b5, b4, b3, b2, b1, b0,
        c, mjr,
        reset_, clock
    );
endmodule

module ParteOperativa(
    b8, b7, b6, b5, b4, b3, b2, b1, b0,
    c, mjr,
    soc, out,
    eoc, reset_, clock, x
);
    input b8, b7, b6, b5, b4, b3, b2, b1, b0;
    output c;

    input reset_, clock, eoc;
    input[7:0] x;
    output out, soc;
    reg OUT, SOC;
    assign out = OUT, soc = SOC;
    reg[7:0] X0, X1, X2;

    output[2:0] mjr;
    reg[2:0] MJR;
    assign mjr = MJR;
    
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;
    localparam Sr0 = 4, Sr1 = 5, Sr2 = 6; 

    assign c = eoc;

    always @(reset_ == 0) begin SOC = 0; end
    always @(posedge clock) if(reset_ == 1) begin
        casex ({b1, b0})
            2'b00: SOC <= 0;
            2'b01: SOC <= SOC;
            2'b10: SOC <= 1; 
        endcase
    end

    always @(reset_ == 0) begin OUT = 0; end
    always @(posedge clock) if(reset_ == 1) begin
        casex({b8, b2})
            2'b00: OUT <= OUT;
            2'b01: OUT <= (X0 + X1 + X2 >= 164) ? 1 : 0;
            2'b10: OUT <= 0;
        endcase
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(b3)
            1'b0: X0 <= X0;
            1'b1: X0 <= x;
        endcase
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex(b4)
            1'b0: X1 <= X1;
            1'b1: X1 <= X0;
        endcase
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex(b5)
            1'b0: X2 <= X2;
            1'b1: X2 <= X0;
        endcase
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex({b7,b6})
            2'b00: MJR <= S1;
            2'b01: MJR <= S2;
            2'b10: MJR <= MJR;
        endcase
    end

endmodule

module ParteControllo (
    b8, b7, b6, b5, b4, b3, b2, b1, b0,
    c, mjr,
    reset_, clock
);
    input c;
    output b8, b7, b6, b5, b4, b3, b2, b1, b0;
    input[2:0] mjr;
    input reset_, clock;

    reg[2:0] STAR;

    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3,
               Sr0 = 4, Sr1 = 5, Sr2 = 6;
    
    assign {b5, b4, b3, b2, b1, b0, b8, b7, b6} =
            (STAR == S0)  ? 9'b000000100 :
            (STAR == S1)  ? 9'b010001001 :
            (STAR == S2)  ? 9'b100001010 :
            (STAR == S3)  ? 9'b000101011 :
            (STAR == Sr0) ? 9'b000010011 :
            (STAR == Sr1) ? 9'b000000011 :
          /*(STAR == Sr2)*/ 9'b001001011;
    
    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: STAR <= Sr0;
            S1: STAR <= Sr0;
            S2: STAR <= Sr0;
            S3: STAR <= S0;

            Sr0: STAR <= c ? Sr0 : Sr1;
            Sr1: STAR <= ~c ? Sr1 : Sr2;
            Sr2: STAR <= mjr;
        endcase
    end

/*
        u-addr | u-codice  | u-codice T | u-codice F | u-type
        000    | 000000100 |    100     |   100      | 0
        001    | 010001001 |    100     |   100      | 0
        010    ... <- quaderno giallo
*/

endmodule