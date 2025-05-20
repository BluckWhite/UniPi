module ABC (
    soc, eoc, x, out,
    reset_, clock
);
    input eoc, reset_, clock;
    input[7:0] x;
    output out, soc;
    reg OUT, SOC;
    assign out = OUT, soc = SOC;

    reg[2:0] STAR;
    reg[2:0] MJR;
    
    reg[7:0] X0, X1, X2;

    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;
    localparam Sr0 = 4, Sr1 = 5, Sr2 = 6; 

    always @(reset_ == 0) begin
        STAR <= S0;
        SOC <= 0;
        OUT <= 0;        
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: begin
                STAR <= Sr0;
                MJR <= S1;
                SOC <= 0;
                OUT <= 0;
            end
            S1: begin
                X1 <= X0; 
                STAR <= Sr0;
                MJR <= S2;
            end
            S2: begin
                X2 <= X0;
                STAR <= Sr0;
                MJR <= S3;
            end
            S3: begin
                OUT <= (X0 + X1 + X2 >= 164) ? 1 : 0;
                STAR <= S0;
            end

            Sr0: begin
                SOC <= 1;
                STAR <= (eoc == 1) ? Sr0 : Sr1;
            end
            Sr1: begin
                SOC <= 0;
                STAR <= (eoc == 0) ? Sr1 : Sr2;
            end
            Sr2: begin
                X0 <= x;
                STAR <= MJR;
            end
        endcase
    end


endmodule