module ABC(soc1, eoc1, x1,
           soc2, eoc2, x2,
           out, reset_, clock);

    output soc1, soc2;
    reg SOC;
    assign soc1 = SOC;
    assign soc2 = SOC;

    input eoc1, eoc2;

    input[7:0] x1, x2;
    output out;
    reg OUT;
    assign out = OUT;

    input reset_, clock;

    wire[7:0] media;
    MEDIA m(x1,x2,media);

    reg[7:0] COUNT;
    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    always @(reset_ == 0) begin
        OUT <= 0;
        SOC <= 0;
        STAR <= S0;
        COUNT <= 0;
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: begin 
                OUT <= 0;
                SOC <= 1;
                STAR <= ( {eoc1, eoc2} == 2'B00 ) ? S1 : S0;
            end
            S1: begin
                SOC <= 0;
                STAR <= ( {eoc1, eoc2} == 2'B11 ) ? S2 : S1;
                COUNT <= media;
            end
            S2: begin
                STAR <= (COUNT == 0) ? S0 : S3;
            end
            S3: begin                
                OUT <= 1;
                COUNT <= COUNT - 1;
                STAR <= (COUNT == 1) ? S0 : S3;
            end
        endcase
    end
endmodule

module MEDIA(x1, x2, m);

    input[7:0] x1, x2;
    output[7:0] m;

    wire[8:0] s;

    add #(.N(8)) a(.x(x1),.y(x2),.c_in(1'B0),.c_out(s[8]),.s(s[7:0]));
    assign m = s[8:1];

endmodule