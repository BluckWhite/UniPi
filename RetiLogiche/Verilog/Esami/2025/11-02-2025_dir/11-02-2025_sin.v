module ABC (
    addr, data,
    ior_, iow_,
    out,
    clock, reset_
);
    input clock, reset_;
    input[7:0] data;
    output[15:0] addr;
    output[11:0] out;
    output ior_, iow_;

    wire[2:0] mjr;
    wire c0;
    wire b8, b7, b6, b5, b4, b3, b2, b1, b0;

    PARTE_OPERATIVA PO(
        addr, data, ior_, iow_, out, clock, reset_,
        b8, b7, b6, b5, b4, b3, b2, b1, b0, c0,
        mjr
    );
    PARTE_CONTROLLO PC(
        clock, reset_,
        b8, b7, b6, b5, b4, b3, b2, b1, b0, c0,
        mjr
    );

endmodule

/*
        u-Addr  |  u-Code   | u-Addr T | u-Addr F | u-Type
          000   | 000000000 |   101    |   101    |  0
          001   | 001010010 |   010    |   000    |  0
          010   | 000100010 |   101    |   101    |  0
          011   | 010110010 |   101    |   101    |  0
          100   | 101010010 |   000    |   000    |  0
          101   | 001010011 |   110    |   110    |  0
          110   | 001010110 |   111    |   111    |  0
          111   | 001011X10 |   XXX    |   XXX    |  1
*/


module PARTE_CONTROLLO (
    clock, reset_,
    b8, b7, b6, b5, b4, b3, b2, b1, b0, c0,
    mjr
);
    input clock, reset_;
    output b8, b7, b6, b5, b4, b3, b2, b1, b0;
    input c0;

    input[2:0] mjr;
    reg[2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4,
               Sin_0 = 5, Sin_1 = 6, Sin_2 = 7;

    assign {b8, b7, b6, b5, b4, b3, b2, b1, b0} = (STAR == S0)    ? 9'b000000000 :
                                                  (STAR == S1)    ? 9'b001010010 :
                                                  (STAR == S2)    ? 9'b000100010 :
                                                  (STAR == S3)    ? 9'b010110010 :
                                                  (STAR == S4)    ? 9'b101010010 :
                                                  (STAR == Sin_0) ? 9'b001010011 :
                                                  (STAR == Sin_1) ? 9'b001010110 :
                                                /*(STAR == Sin_2)*/ 9'b001011X10 ;

    always @(reset_ == 0) STAR <= S0;
    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: STAR <= Sin_0;
            S1: STAR <= c0 ? S2 : S0;
            S2: STAR <= Sin_0;
            S3: STAR <= Sin_0;
            S4: STAR <= S0;

            Sin_0: STAR <= Sin_1;
            Sin_1: STAR <= Sin_2;
            Sin_2: STAR <= mjr;
        endcase
    end

endmodule

module PARTE_OPERATIVA (
    addr, data, ior_, iow_, out, clock, reset_,
    b8, b7, b6, b5, b4, b3, b2, b1, b0, c0,
    mjr
);
    input clock, reset_;
    input[7:0] data;
    output[15:0] addr;
    output[11:0] out;
    output ior_, iow_;

    output[2:0] mjr;

    input b8, b7, b6, b5, b4, b3, b2, b1, b0;
    output c0;
    
    reg[15:0] ADDR; assign addr = ADDR;
    reg[11:0] OUT; assign out = OUT;
    reg IOR_; assign ior_ = IOR_;
    reg[7:0] APP0, APP1;
    reg[7:0] A, B;

    reg[2:0] MJR; assign mjr = MJR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4,
               Sin_0 = 5, Sin_1 = 6, Sin_2 = 7;

    wire[8:0] ris;
    assign ris = A + B;
    assign c0 = APP0[0];

    always @(posedge clock) if(reset_ == 1) begin
        casex(b0)
            1'b0: ADDR <= ADDR;
            1'b1: ADDR <= {APP1, APP0};
        endcase
    end

    always @(reset_ == 0) OUT <= 0; 
    always @(posedge clock) if(reset_ == 1) begin
        casex(b1)
            1'b0: OUT <= ris;
            1'b1: OUT <= OUT;
        endcase
    end

    always @(reset_ == 0) IOR_ <= 1;
    always @(posedge clock) if(reset_ == 1) begin
        casex({b3, b2})
            2'b00: IOR_ <= IOR_;
            2'b01: IOR_ <= 0;
            2'b1X: IOR_ <= 1;
        endcase
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex({b3, b5, b4})
            3'b000: APP0 <= 8'H00;        
            3'b001: APP0 <= APP0;
            3'b010: APP0 <= 8'H01;
            3'b011: APP0 <= 8'H20;
            3'b101: APP0 <= data;
        endcase
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(b6)
            1'b0: APP1 <= 8'H01;
            1'b1: APP1 <= APP1;
        endcase
    end

    always @(reset_ == 0) A <= 0;
    always @(posedge clock) if(reset_ == 1) begin
        casex(b7)
            1'b0: A <= A;
            1'b1: A <= APP0;
        endcase
    end

    always @(reset_ == 0) B <= 0;
    always @(posedge clock) if(reset_ == 1) begin
        casex(b8)
            1'b0: B <= B;
            1'b1: B <= APP0;
        endcase
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex({b5, b4})
            2'b00: MJR <= S1;
            2'b01: MJR <= MJR;
            2'b10: MJR <= S3;
            2'b11: MJR <= S4;
        endcase
    end
endmodule