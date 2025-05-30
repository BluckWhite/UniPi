module ABC (
    rfd_x, rfd_y, dav_x, dav_y,
    x, y, reset_, clock, out
);
    input dav_y, dav_x;
    output rfd_x, rfd_y;
    input[7:0] x, y;
    input reset_, clock;
    output out;

    reg RFD; assign rfd_x = RFD, rfd_y = RFD;
    reg[7:0] COUNT;
    reg OUT; assign out = OUT;

    reg[1:0] STAR; localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    wire[7:0] max;
    MAX maxV(x, y, max);

    always @(reset_ == 0) #1 begin
        STAR <= S0;
        OUT <= 0;
        RFD <= 1;
    end
    always @(posedge clock) if(reset_ == 1) #3
        casex (STAR)
            S0: begin
                RFD <= 1;
                STAR <= {dav_x, dav_y} == 2'b00 ? S1 : S0;  
            end
            S1: begin
                COUNT <= max;
                RFD <= 0;
                STAR <= S2;
            end
            S2: begin
                OUT <= 1;
                COUNT <= COUNT - 1;
                STAR <= (COUNT == 1) ? S3 : S2;
            end
            S3: begin
                OUT <= 0;
                STAR <= {dav_x, dav_y} == 2'b11 ? S0 : S3;
            end
        endcase
endmodule

module MAX (
    x, y, z
);
    input[7:0] x, y;
    output[7:0] z;

    wire w1;
    add #(.N(8)) ADDER(.x(x), .y(~y), .c_in(1'b1), .c_out(w1));
    
    assign z = w1 ? x : y;
endmodule