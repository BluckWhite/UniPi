module ABC(
    soc, eoc, x,
    m, z,
    reset_, clock
);

    input eoc, reset_, clock;
    output soc, z;
    input[7:0] x;
    output[7:0] m;

    reg SOC, Z; assign soc = SOC, z = Z;
    reg[7:0] M; assign m = M;

    reg[7:0] BUFFER;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2;

    wire[7:0] ris;
    MEDIA_ESPONENZIALE ME(BUFFER, x, ris);
    
    always @(reset_ == 0) begin
        BUFFER <= 8'B0;
        Z <= 0;
        SOC <= 0;
        STAR <= S0;
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                SOC <= 1;
                Z <= 0;
                STAR <= (eoc == 0) ? S1 : S0;
            end
            S1: begin
                SOC <= 0;
                M <= ris;
                STAR <= (eoc == 0) ? S1 : S2;
            end 
            S2: begin
                BUFFER <= M;
                Z <= 1;
                STAR <= S0;
            end
        endcase
    end
endmodule

// Serve il filo per BUFFER? no.

module MEDIA_ESPONENZIALE (
    buff, x, ris
);
    input[7:0] buff, x;
    output[7:0] ris;

    wire[9:0] w1;
    
    mul_add_nat #(.N(8), .M(2)) mul(
        .x(buff), .c(8'b0), .y(2'd3), .m(w1)
    );

    add #(.N(8)) somm(
        .x(w1[9:2]), .y({2'b0, x[7:2]}), .c_in(1'b0), .s(ris)
    );

endmodule