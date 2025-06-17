module ABC (
    soc, eoc,
    n_0, k,
    reset_, clock
);
    input soc;
    output eoc;
    input reset_, clock;
    input[7:0] n_0;
    output[7:0] k;

    wire b5, b3, b2, b1, b0, c1, c0;

    PARTE_CONTROLLO PC(reset_, clock,
        b5, b3, b2, b1, b0, c1, c0
    );
    PARTE_OPERATIVA PO(soc, eoc,
        n_0, k,
        reset_, clock,
        b5, b3, b2, b1, b0, c1, c0
    );

endmodule

module PARTE_CONTROLLO (
    reset_, clock,
    b5, b3, b2, b1, b0, c1, c0
);
    input reset_, clock;
    output b5, b3, b2, b1, b0;
    input c1, c0;

    reg[2:0] STAR; 
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if(reset_ == 1)
        casex (STAR)
            S0: STAR <= c0 ? S1 : S0;
            S1: STAR <= c1 ? S3 : S2;
            S2: STAR <= S1;
            S3: STAR <= c0 ? S3 : S4;
            S4: STAR <= c0 ? S0 : S4;
        endcase

    assign {b5, b3, b2, b1, b0} = (STAR == S0) ? 5'b00000 :
                                  (STAR == S1) ? 5'b00101 :
                                  (STAR == S2) ? 5'b11X10 :
                                  (STAR == S3) ? 5'b10110 :
                                /*(STAR == S4)*/ 5'b10100;

endmodule


module PARTE_OPERATIVA (
    soc, eoc,
    n_0, k,
    reset_, clock,
    b5, b3, b2, b1, b0, c1, c0
);
    input soc;
    output eoc;
    input reset_, clock;
    input[7:0] n_0;
    output[7:0] k;

    input b5, b3, b2, b1, b0;
    output c1, c0;

    reg EOC; assign eoc = EOC;
    reg[7:0] K; assign k = K;


    reg[13:0] X_0;
    wire[13:0] x_1;
    
    CALCOLO_ITERAZIONE CI(X_0, x_1);

    assign c1 = (X_0 == 1) ? 1 : 0, c0 = soc;

    always @(reset_ == 0) X_0 <= 0; 
    always @(posedge clock) if (reset_ == 1)
        casex ({b5,b0})
            2'b00: X_0 <= {6'b0, n_0};
            2'b01: X_0 <= x_1;
            2'b10: X_0 <= X_0;
        endcase

    always @(reset_ == 0) EOC <= 1;
    always @(posedge clock) if (reset_ == 1)
        casex ({b1,b0})
            2'b00: EOC <= 1;
            2'b01: EOC <= 0;
            2'b10: EOC <= EOC;
        endcase

    always @(reset_ == 0) K <= 0;
    always @(posedge clock) if (reset_ == 1)
        casex ({b3,b2})
            2'b00: K <= 0;
            2'b01: K <= K + 1;
            2'b1X: K <= K;
        endcase
endmodule


module CALCOLO_ITERAZIONE (
    x_0, x_1
);
    input[13:0] x_0;
    output[13:0] x_1;

    wire[15:0] odd_0;
    mul_add_nat #(.N(2), .M(14)) MUL(.x(2'b11), .y(x_0), .c(2'b1), .m(odd_0));

    assign x_1 = (x_0[0] == 1'b0) ? {1'b0, x_0[13:1]} : odd_0[13:0];
endmodule