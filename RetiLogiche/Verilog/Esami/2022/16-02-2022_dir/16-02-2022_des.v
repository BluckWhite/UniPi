module ABC (
    rxd, txd, clock_rx, clock_tx, reset_
);
    input rxd, clock_rx, clock_tx, reset_;
    output txd;

    wire dav_, rfd;
    wire[7:0] data;

    RX rx(rxd, clock_rx, reset_, dav_, rfd, data);
    TX tx(txd, clock_tx, reset_, dav_, rfd, data);

endmodule

module RX (
    rxd, clock_rx, reset_,
    dav_, rfd, data
);
    localparam mark = 1, space = 0;

    input clock_rx, reset_, rfd;
    input rxd;
    output[7:0] data;
    output dav_;

    reg[7:0] BUFFER; assign data = BUFFER;
    reg DAV_; assign dav_ = DAV_;
    reg[2:0] COUNT_BYTE;
    reg[3:0] COUNT_CLK;

    reg[2:0] STAR; 
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    always @(reset_ == 0) begin
        STAR <= S0;
        DAV_ <= 1;
        COUNT_BYTE <= 7;
        COUNT_CLK <= 15;
        STAR <= S0;
    end
    always @(posedge clock_rx) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                DAV_ <= 1;
                COUNT_CLK <= 15;
                COUNT_BYTE <= 7;
                STAR <= (rxd == space) ? S1 : S0;
            end
            S1: begin
                COUNT_CLK <= COUNT_CLK - 1;
                BUFFER[0] <= rxd;
                STAR <= (COUNT_CLK == 0) ? S2 : S1;
            end
            S2: begin
                BUFFER <= {BUFFER[6:0], 1'b0};
                COUNT_CLK <= 15;
                COUNT_BYTE <= COUNT_BYTE - 1;
                STAR <= (COUNT_BYTE == 0) ? S3 : S1;
            end
            S3: begin
                STAR <= rfd ? S4 : S3;
            end
            S4: begin
                DAV_ <= 0;
                STAR <= rfd ? S4 : S0;
            end
        endcase
    end
endmodule

module TX (
    txd, clock_tx, reset_,
    dav_, rfd, data
);
    localparam mark = 1, space = 0;

    input clock_tx, reset_, dav_;
    input[7:0] data;
    output rfd, txd;

    reg[7:0] BUFFER;
    reg RFD, TXD; assign rfd = RFD, txd = TXD;
    reg[2:0] COUNT;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2;

    always @(reset_ == 0) begin
        TXD <= mark;
        RFD <= 1;
        COUNT <= 7;
        STAR <= S0;
    end
    always @(posedge clock_tx) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                RFD <= 1;
                BUFFER <= data;
                TXD <= mark;
                COUNT <= 7;
                STAR <= dav_ ? S0 : S1;    
            end
            S1: begin
                RFD <= 0;
                TXD <= space;
                STAR <= S2;
            end
            S2: begin
                TXD <= BUFFER[7];
                BUFFER <= {BUFFER[6:0], 1'b0};
                COUNT <= COUNT - 1;
                STAR <= (COUNT == 0) ? S0 : S2;
            end
        endcase
    end
endmodule