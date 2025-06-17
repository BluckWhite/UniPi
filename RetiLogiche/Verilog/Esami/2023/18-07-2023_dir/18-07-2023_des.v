module ABC (
    clock, reset_,
    addr, data, ior_, iow_
);
    input clock, reset_;
    output[15:0] addr;
    inout[7:0] data;
    output ior_, iow_;

    reg DIR;
    reg IOR_, IOW_; assign ior_ = IOR_, iow_ = IOW_;
    reg[15:0] ADDR; assign addr = ADDR;
    reg[7:0] DATA; assign data = DIR ? DATA : 8'bZZ;
    reg[7:0] APP1, APP0;

    reg[3:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, 
               S5 = 5, S6 = 6, S7 = 7, S8 = 8, S9 = 9;

    wire [15:0] mul;
    MUL5 m5 (
        .a(APP0), .m(mul)
    );

    always @(reset_ == 0) begin
        STAR <= S0;
        IOR_ <= 1;
        IOW_ <= 1;
        DIR <= 0;
    end
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: begin
                ADDR <= 16'H0100;
                DIR <= 0;
                STAR <= S1;
            end
            S1: begin
                IOR_ <= 0;
                STAR <= S2;
            end
            S2: begin
                APP0 <= data;
                STAR <= S3;
            end
            S3: begin
                IOR_ <= 1;
                STAR <= (APP0[0] == 1) ? S4 : S1;
            end
            S4: begin
                ADDR <= 16'H0101;
                STAR <= S5;
            end
            S5: begin
                IOR_ <= 0;
                STAR <= S6;
            end
            S6: begin
                APP0 <= data;
                IOR_ <= 1;
                STAR <= S7;
            end
            S7: begin
                ADDR <= 16'H0121;
                DIR <= 1;
                APP1 <= mul[15:8];
                APP0 <= mul[7:0];
                STAR <= S8;
            end
            S8: begin
                IOW_ <= 0;
                DATA <= APP1;
                STAR <= S9;
            end
            S9: begin
                DATA <= APP0;
                IOW_ <= 1;
                STAR <= S0;
            end
        endcase        
    end

endmodule

// !!! è di stea, falla da solo.

module MUL5(a, m);
    input [7:0] a;
    output [15:0] m;

    wire [9:0] a1_ext;
    assign a1_ext = {2'b00, a};
    wire [9:0] a4_ext;
    assign a4_ext = {a, 2'b00};
    
    wire [9:0] sum;
    wire c_out;
    add #( .N(10) ) s (
        .x(a1_ext), .y(a4_ext), .c_in(1'b0),
        .s(sum), .c_out(c_out)
    );

    assign m = { 5'h00, c_out, sum };
endmodule