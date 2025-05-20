module ABC (
    rxd, ow, signal, out,
    clock, reset_
);
    input rxd, clock, reset_;
    output ow, signal;
    output[7:0] out;
    wire b0, b1, b2, b3, b4, c0, c1;

    ParteOperativa PO(rxd, ow, signal, out,
                      clock, reset_,
                      b0, b1, b2, b3, b4,
                      c0, c1);

    ParteControllo PC(clock, reset_,
                      b0, b1, b2, b3, b4,
                      c0, c1);

endmodule

module ParteControllo (
    clock, reset_,
    b0, b1, b2, b3, b4,
    c0, c1);
    
    reg[2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    input clock, reset_;
    input c0, c1;
    output b0, b1, b2, b3, b4;

    assign {b4, b3, b2, b1, b0} = 
            (STAR == S1) ? 'B01001:
            (STAR == S2) ? 'B10001:
            (STAR == S3) ? 'B00101:
            (STAR == S4) ? 'B00010:
            /* DEFAULT */  'B00000;

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if (reset_ == 1)
        casex(STAR)
            S0: STAR <= (c0 == 1) ? S0 : S1;
            S1: STAR <= (c0 == 1) ? S2 : S1;
            S2: STAR <= (c1 == 1) ? S3 : S0;
            S3: STAR <= S4;
            S4: STAR <= S0;
        endcase

endmodule

module ParteOperativa(
    rxd, ow, signal, out,
    clock, reset_,
    b0, b1, b2, b3, b4,
    c0, c1
);

    input rxd, clock, reset_;
    output ow, signal;
    output[7:0] out;

    input b0, b1, b2, b3, b4;
    output c0, c1;

    assign c0 = rxd, 
           c1 = COUNT[2] & COUNT[1] & COUNT[0];

    reg OW, SIGNAL; assign ow = OW, signal = SIGNAL;
    reg[7:0] OUT; assign out = OUT;

    reg[7:0] BYTE_PREV, BYTE_CURR;
    reg[2:0] COUNT;
    reg[3:0] COUNT_RXD;

    wire[7:0] sum;
    wire sum_ow;
    PROSSIMO_S ps(.x_curr(BYTE_CURR), .x_prev(BYTE_PREV), .s(sum), .ow(sum_ow));

    always @(posedge clock) if(reset_ == 1)
        casex({b1,b0})
            'B00: OW <= 0;
            'B01: OW <= OW;
            'B10: OW <= sum_ow;        
        endcase

    always @(posedge clock) if(reset_ == 1)
        casex({b1,b0})
            'B00: SIGNAL <= 0;
            'B01: SIGNAL <= SIGNAL;
            'B10: SIGNAL <= ~sum_ow;
        endcase
    
    always @(posedge clock) if(reset_ == 1)
        casex(b2)
            'B0: OUT <= sum;
            'B1: OUT <= OUT;
        endcase
    
    always @(reset_ == 0) COUNT_RXD <= 0;
    always @(posedge clock) if(reset_ == 1)
        casex({b4,b3})
            'B00: COUNT_RXD <= COUNT_RXD;
            'B01: COUNT_RXD <= COUNT_RXD + 1;
            'B10: COUNT_RXD <= 0;      
        endcase

    always @(reset_ == 0) COUNT <= 0;
    always @(posedge clock) if(reset_ == 1)
        casex({b1,b4})
            'B00: COUNT <= COUNT;
            'B01: COUNT <= COUNT + 1;
            'B10: COUNT <= 0; 
        endcase

    always @(reset_ == 0) BYTE_CURR <= 0;
    always @(posedge clock) if(reset_ == 1)
        casex({b1,b4})
            'B00: BYTE_CURR <= BYTE_CURR;
            'B01: BYTE_CURR <= {~COUNT_RXD[3], BYTE_CURR[7:1]};
            'B10: BYTE_CURR <= 0;
        endcase

    always @(posedge clock) if(reset_ == 1)
        casex(b1)
            'B0: BYTE_PREV <= BYTE_PREV;
            'B1: BYTE_PREV <= sum_ow ? 0 : BYTE_CURR;
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