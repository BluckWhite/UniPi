module ABC (
    soc, eoc, x,
    m, z,
    reset_, clock
);
    input eoc, reset_, clock;
    output soc, z;
    input[7:0] x;
    output[7:0] m;

    wire b1, b0, c;

    PARTE_OPERATIVA PO(
        soc, eoc, x,
        m, z,
        reset_, clock,
        b1, b0, c
    );
    PARTE_CONTROLLO PC(
        reset_, clock,
        b1, b0, c
    );

endmodule

module PARTE_OPERATIVA (
        soc, eoc, x,
        m, z,
        reset_, clock,
        b1, b0, c
);
    input eoc, reset_, clock;
    output soc, z;
    input[7:0] x;
    output[7:0] m;

    input b1, b0; output c;

    reg SOC, Z; assign soc = SOC, z = Z;
    reg[7:0] M; assign m = M;
    reg[7:0] BUFFER;

    wire[7:0] ris;
    MEDIA_ESPONENZIALE ME(BUFFER, x, ris);

    assign c = ~eoc;

    // BUFFER
    always @(reset_ == 0) BUFFER <= 0;
    always @(posedge clock) if(reset_ == 1) begin
        casex(b0)
            0: BUFFER <= BUFFER;
            1: BUFFER <= M;
        endcase
    end

    // Z
    always @(reset_ == 0) Z <= 0;
    always @(posedge clock) if(reset_ == 1) begin
        casex({b0, b1})
            'b00: Z <= 0;
            'b01: Z <= Z;
            'b10: Z <= 1;
        endcase
    end

    // SOC
    always @(reset_ == 0) SOC <= 0;
    always @(posedge clock) if(reset_ == 1) begin
        casex({b0, b1})
            'b00: SOC <= 1;
            'b01: SOC <= 0;
            'b10: SOC <= SOC;
        endcase
    end


    // M
    always @(posedge clock) if(reset_ == 1) begin
        casex(b1)
            0: M <= M;
            1: M <= ris;
        endcase
    end

endmodule

module PARTE_CONTROLLO (
    reset_, clock,
    b1, b0, c
);
    input clock, reset_;
    input c; output b1, b0;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2;

    assign {b1, b0} = (STAR == S0) ? 'b00 :
                      (STAR == S1) ? 'b10 :
                     /*STAR == S2*/  'b01;

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: STAR <= c ? S1 : S0;
            S1: STAR <= c ? S1 : S2;
            S2: STAR <= S0;
        endcase
    end

endmodule

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