module ABC (
    soc, eoc,
    n_0, k,
    reset_, clock
);
    input soc;
    output eoc;
    reg EOC; assign eoc = EOC;

    input reset_, clock;
    input[7:0] n_0;
    output[7:0] k;
    reg[7:0] K; assign k = K;

    reg[2:0] STAR; 
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    reg[13:0] X_0;
    wire[13:0] x_1;
    
    CALCOLO_ITERAZIONE CI(X_0, x_1);

    always @(reset_ == 0) begin
        STAR <= S0;
        X_0 <= 0;
        EOC <= 1;
        K <= 0;
    end

    always @(posedge clock) if(reset_ == 1)
        casex (STAR)
            S0: begin
                X_0 <= {6'b0, n_0};
                EOC <= 1;
                K <= 0;
                STAR <= soc ? S1 : S0;
            end
            S1: begin
                EOC <= 0;
                X_0 <= x_1;
                STAR <= (X_0 == 1) ? S3 : S2;
            end
            S2: begin
                K <= K + 1;
                STAR <= S1;
            end
            S3: begin
                STAR <= soc ? S3 : S4;
            end
            S4: begin
                EOC <= 1;
                STAR <= soc ? S0 : S4;
            end
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