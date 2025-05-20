module ABC(soc1, eoc1, x1,
           soc2, eoc2, x2,
           out, reset_, clock);

    output soc1, soc2;
    input eoc1, eoc2;
    input[7:0] x1, x2;
    output out;

    input reset_;
    input clock;

    wire c0, c1, c2, c3;
    wire[1:0] b1_b0;

    Parte_Operativa PO(soc1, eoc1, x1,
                       soc2, eoc2, x2,
                       out, reset_, clock,
                       c0, c1, c2, c3, b1_b0);
    Parte_Controllo PC(c0, c1, c2, c3, b1_b0,
                       reset_, clock);
endmodule

module MEDIA(x1, x2, m);

    input[7:0] x1, x2;
    output[7:0] m;

    wire[8:0] s;

    add #(.N(8)) a(.x(x1),.y(x2),.c_in(1'B0),.c_out(s[8]),.s(s[7:0]));
    assign m = s[8:1];

endmodule

// --- Parte Controllo ----------------------------------------------

module Parte_Controllo(c0, c1, c2, c3, b1_b0,
                       reset_, clock);
    input clock, reset_;
    input c0, c1, c2, c3;
    output b1_b0;

    reg [1:0] STAR;
    parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3;
    assign b1_b0[1] = (STAR == S1) ? 1 : (STAR == S3) ? 1 : 0,
           b1_b0[0] = (STAR == S0) ? 1 : (STAR == S2) ? 1 : 0;
    
    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if(reset_ == 1) #3
        casex(STAR)
            S0: begin STAR <= (c0 == 1) ? S1 : S0; end
            S1: begin STAR <= (c1 == 1) ? S2 : S1; end
            S2: begin STAR <= (c3 == 1) ? S0 : S3; end
            S3: begin STAR <= (c2 == 1) ? S0 : S3; end
        endcase
endmodule

//!------------------------------------------------------------------

// --- Parte Operativa ----------------------------------------------

module Parte_Operativa(soc1, eoc1, x1,
                       soc2, eoc2, x2,
                       out, reset_, clock,
                       c0, c1, c2, c3, b1_b0);

    input reset_, clock;
    input eoc1, eoc2;

    input[7:0] x1, x2;
    output out;
    reg OUT;
    assign out = OUT;

    wire[7:0] media;
    MEDIA m(x1,x2,media);

    output soc1, soc2;
    reg SOC;
    assign soc1 = SOC;
    assign soc2 = SOC;

    assign c0 = ~eoc1 & ~eoc2,
           c1 = eoc1 & eoc2,
           c2 = COUNT,
           c3 = ~COUNT;
    
    always @(reset_ == 0) begin OUT <= 0 end
    always @(reset_ == 0) begin COUNT <= 0 end
    always @(reset_ == 0) begin SOC <= 0 end

    always @(posedge clock) if(reset_ == 1) begin
        casex()
        endcase

endmodule