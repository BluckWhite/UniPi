module ABC (
    rxd, ow, signal, out,
    clock, reset_
);
    input rxd, clock, reset_;
    output ow, signal;
    output[7:0] out;

    reg OW, SIGNAL; assign ow = OW, signal = SIGNAL;
    reg[7:0] OUT; assign out = OUT;

    reg[7:0] BYTE_PREV, BYTE_CURR;
    reg[2:0] COUNT;
    reg[3:0] COUNT_RXD;

    reg[2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
    parameter mark = 1, space = 0;

    wire[7:0] sum;
    wire sum_ow;
    PROSSIMO_S ps(.x_curr(BYTE_CURR), .x_prev(BYTE_PREV), .s(sum), .ow(sum_ow));

    always @(reset_ == 0) begin
        STAR <= S0;
        BYTE_PREV <= 0;
        BYTE_CURR <= 0;
        COUNT <= 0;
        COUNT_RXD <= 0;
    end

    always @(posedge clock) if(reset_ == 1)
        casex(STAR)
            S0: begin
                STAR <= (rxd == mark) ? S0 : S1;
                SIGNAL <= 0;
                OW <= 0;
            end
            S1: begin
                STAR <= (rxd == mark) ? S2 : S1;
                COUNT_RXD <= COUNT_RXD + 1;
            end
            S2: begin
                COUNT <= COUNT + 1;
                STAR <= (COUNT == 7) ? S3 : S0;
                COUNT_RXD <= 0;
                BYTE_CURR <= {~COUNT_RXD[3], BYTE_CURR[7:1]};
            end
            S3: begin
                OUT <= sum;
                STAR <= S4;
            end
            S4: begin
                SIGNAL <= ~sum_ow;
                OW <= sum_ow;
                BYTE_PREV <= sum_ow ? 0 : BYTE_CURR;
                BYTE_CURR <= 0;
                COUNT <= 0;
                STAR <= S0;
            end
        endcase


endmodule

module PROSSIMO_S (
    x_curr, x_prev,
    s, ow
);
    input[7:0] x_curr, x_prev;
    output[7:0] s;
    output ow;

    add #(.N(8)) summ(.x(x_curr), .y(x_prev), .c_in(1'B0), .ow(ow), .s(s));

endmodule