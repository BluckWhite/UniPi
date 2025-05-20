module ABC (
    soc, eoc,
    b, c, l_0, r_0, x_0,
    reset_, clock
);
    input soc, clock, reset_;
    input[9:0] b, c; 
    input[7:0] l_0, r_0;
    
    output[7:0] x_0;
    reg[7:0] X; assign x_0 = X;
    
    output eoc;
    reg EOC; assign eoc = EOC;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2;

    reg[9:0] B, C;
    reg[7:0] L_0, R_0;
    reg[7:0] L_1, R_1;

    wire[7:0] l_1, r_1;
    PROSSIMO_INTERVALLO PI(b, c, L_0, R_0, l_1, r_1);

    always @(reset_ == 0) begin
        STAR <= S0;
        EOC <= 1;
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                EOC <= 1;
                B <= b;
                C <= c;
                L_0 <= l_0;
                R_0 <= r_0;
                STAR <= (soc == 0) ? S0 : S1;
            end 
            S1: begin
                EOC <= 0;
                L_0 <= l_1;
                R_0 <= r_1;
                STAR <= (l_1 + 1 == r_1) ? S2 : S1;
            end
            S2: begin
                STAR <= (soc == 0) ? S0 : S2;
                X <= r_1;
            end
        endcase
    end

endmodule

module PROSSIMO_INTERVALLO (
    b, c, l_0, r_0,
    l_1, r_1
);
    input[9:0] b, c;
    input[7:0] l_0, r_0;
    output[7:0] l_1, r_1;

    // --- Calcolo di m
    
    wire[7:0] m;
    wire c_out;

    add #(.N(8)) Adder(.x(l_0), .y(r_0), .c_in(1'b0), 
                       .c_out(c_out), .s(m));

    assign m = {c_out, m[7:1]};

    // --- Calcolo di f(m)

    // --- b*m + c
    wire[17:0] bm_c;
    mul_add_nat #(.N(10), .M(8)) Mul_1(.x(b), .y(m), .c(c),
                                       .m(bm_c));

    // --- Ok
    wire[15:0] m_sqr;
    mul_add_nat #(.N(8), .M(8)) Mul_2(.x(m), .y(m), .c(8'b0),
                                      .m(m_sqr));


    wire[19:0] ris;
    diff #(.N(20)) Sub(.x({4'b0, m_sqr}), .y({2'b0, bm_c}), .b_in(1'b0), 
                      .d(ris));

    assign l_1 = ris[19] ? m : l_0;
    assign r_1 = ris[19] ? r_0 : m;

endmodule