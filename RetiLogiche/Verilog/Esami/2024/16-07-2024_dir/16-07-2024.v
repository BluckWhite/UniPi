module ABC (
    soc, eoc, x, out,
    reset_, clock
);
    input eoc, reset_, clock;
    input[7:0] x;
    output soc, out;
    reg SOC, OUT;  
    assign soc = SOC, out = OUT;

    reg[1:0] COUNT;
    reg[7:0] in_BUFFER;
    reg[8:0] sum_BUFFER;

    reg[3:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3,
            S4 = 4, S5 = 5, S6 = 6;

    always @(reset_ == 0) begin
        COUNT <= 0;
        STAR <= S6;
        SOC <= 0;
        OUT <= 0;
        sum_BUFFER <= 0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S6: begin
                    STAR <= S0;
                    SOC <= 0;
            end
            S0: begin
                    STAR <= (eoc == 0) ? S1 : S0;
                    SOC <= 1;
                    OUT <= 0;
            end
            S1: begin
                    STAR <= (COUNT == 0) ? S3 : S2;
                    COUNT <= COUNT-1;
            end
            S2: begin
                    STAR <= (eoc == 1) ? S3 : S2;
                    SOC <= 0;
                    in_BUFFER <= x;
            end
            S3: begin
                    STAR <= (COUNT == 0) ? S4 : S6;
                    sum_BUFFER <= sum_BUFFER + in_BUFFER;
            end
            S4: begin
                    STAR <= (sum_BUFFER >= 164) ? S5 : S6;
                    COUNT <= 3;
                    sum_BUFFER <= 0;
            end
            S5: begin
                    STAR <= S6;
                    OUT <= 1;
            end
        endcase
    end

endmodule