module ABC (
    x, y,
    soc, eoc, out,
    reset_, clock
);
    input clock, reset_;
    input soc;
    output eoc;
    input[7:0] y;
    output[7:0] x;
    output[15:0] out;

    reg EOC; assign eoc = EOC;
    reg[7:0] X; assign x = X;
    reg[15:0] OUT; assign out = OUT;

    CHECK CK(X, y, ris);

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2;

    always @(reset_ == 0) begin
        STAR <= S0;
        X <= 0;
        EOC <= 1;
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                EOC <= 1;
                STAR <= soc ? S1 : S0;
            end 
            S1: begin
                EOC <= 0;
                X <= X + 1;
                OUT <= {X, y};
                STAR <= ris ? S2 : S1; 
            end
            S2: begin
                STAR <= soc ? S2 : S0;
            end
        endcase
    end
endmodule

module CHECK (
    x, y, ris
);
    input[7:0] x, y;
    output ris;

    wire[15:0] w1;
    mul_add_nat #(.N(8), .M(8)) MUL(.x(x), .y(y), .c(8'b0), .m(w1));

    comp_nat #(.N(16)) CMP(.a(16'HABB9), .b(w1), .min(ris));

endmodule