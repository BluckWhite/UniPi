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

    reg[15:0] ADDR; assign addr = ADDR;
    reg[11:0] OUT; assign out = OUT;
    reg IOR_; assign ior_ = IOR_;

    reg[7:0] APP0, APP1;
    reg[7:0] A, B;

    reg[2:0] MJR;
    reg[2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4,
               Sin_0 = 5, Sin_1 = 6, Sin_2 = 7;

    wire[8:0] ris;
    assign ris = A + B;

    always @(reset_ == 0) begin
        STAR <= S0;
        A <= 0; B <= 0;
        OUT <= 0;
        IOR_ <= 1;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                OUT <= ris;
                APP0 <= 8'H00;
                APP1 <= 8'H01;
                MJR <= S1;
                STAR <= Sin_0;
            end 
            S1: begin
                STAR <= (APP0[0] == 1) ? S2 : S0;
            end
            S2: begin
                APP0 <= 8'H01;
                APP1 <= 8'H01;
                MJR <= S3;
                STAR <= Sin_0;
            end
            S3: begin
                A <= APP0;
                APP0 <= 8'H20;
                APP1 <= 8'H01;
                MJR <= S4;
                STAR <= Sin_0;
            end
            S4: begin
                B <= APP0;
                STAR <= S0;
            end

            Sin_0: begin
                ADDR <= {APP1, APP0};
                STAR <= Sin_1;
            end
            Sin_1: begin
                IOR_ <= 0;
                STAR <= Sin_2;
            end
            Sin_2: begin
                APP0 <= data;
                IOR_ <= 1;
                STAR <= MJR;
            end
        endcase
    end

endmodule