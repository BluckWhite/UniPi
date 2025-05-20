module ABC (
    soc_vx, eoc_vx, vx,
    soc_vy, eoc_vy, vy,
    x, y, soc_p, eoc_p,
    reset_, clock
);
    input reset_, clock;

    input eoc_vx, eoc_vy;    
    output soc_vx, soc_vy;

    input[3:0] vx, vy;
    output[7:0] x, y;

    input soc_p;
    output eoc_p;

    wire b2, b1, b0, c2, c1, c0;

    ParteOperativa PO(
    soc_vx, eoc_vx, vx,
    soc_vy, eoc_vy, vy,
    x, y, soc_p, eoc_p,
    reset_, clock,
    b2, b1, b0,
    c2, c1, c0);
    ParteControllo PC(reset_, clock,
    b2, b1, b0,
    c2, c1, c0);

endmodule

module ParteOperativa(
    soc_vx, eoc_vx, vx,
    soc_vy, eoc_vy, vy,
    x, y, soc_p, eoc_p,
    reset_, clock,
    b2, b1, b0,
    c2, c1, c0
);
    input reset_, clock;

    input eoc_vx, eoc_vy;    
    output soc_vx, soc_vy;

    input[3:0] vx, vy;
    output[7:0] x, y;

    input soc_p;
    output eoc_p;

    wire[7:0] x_new, y_new;
    PROSSIMA_POSIZIONE PP(X, Y, vx, vy, x_new, y_new);

    output c2, c1, c0;
    input b2, b1, b0;

    reg SOC; assign soc_vx = SOC, soc_vy = SOC;
    reg[7:0] X, Y; assign x = X, y = Y;
    reg EOC; assign eoc_p = EOC;

    // SOC 
    always @(reset_ == 0) begin SOC = 0; end
    always @(posedge clock) if(reset_ == 1) begin
        casex(b1)
            0: SOC <= 0;
            1: SOC <= 1;
        endcase
    end

    // EOC
    always @(reset_ == 0) begin EOC = 1; end
    always @(posedge clock) if(reset_ == 1) begin
        casex(b0)
            0: EOC <= 0;
            1: EOC <= 1;
        endcase
    end


    always @(reset_ == 0) begin X = 0; end
    always @(posedge clock) if(reset_ == 1) begin
        casex(b2)
            0: X <= X;
            1: X <= x_new;
        endcase
    end

    always @(reset_ == 0) begin Y = 0; end 
    always @(posedge clock) if(reset_ == 1) begin
        casex(b2)
            0: Y <= Y;
            1: Y <= y_new;
        endcase
    end

    assign c0 = ~soc_p;
    assign c1 = (~eoc_vx & ~eoc_vy);
    assign c2 = (eoc_vx & eoc_vy);

endmodule

module ParteControllo (
    reset_, clock,
    b2, b1, b0,
    c2, c1, c0
);
    input reset_, clock;
    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    input c2, c1, c0;
    output b2, b1, b0;

    assign {b2, b1, b0} = (STAR == S0) ? 3'b001 :
                          (STAR == S1) ? 3'b010 :
                          (STAR == S2) ? 3'b000 :
                         /*STAR == S3*/  3'b100;

    always @(reset_ == 0) begin STAR = S0; end
    always @(posedge clock) if(reset_ == 1) begin
        casex (STAR)
            S0: STAR <= c0 ? S0 : S1;
            S1: STAR <= c1 ? S2 : S1;
            S2: STAR <= c2 ? S3 : S2;
            S3: STAR <= c0 ? S0 : S3;
        endcase
    end

endmodule

module PROSSIMA_POSIZIONE(x_old, y_old, vx, vy, x_new, y_new);
    input[7:0] x_old, y_old;
    input[3:0] vx, vy;
    output[7:0] x_new, y_new;

    wire ow_x;
    wire[7:0] ris_x;

    wire[7:0] vx_e = {vx[3], vx[3], vx[3], vx[3], vx};
    wire[7:0] vy_e = {vy[3], vy[3], vy[3], vy[3], vy};

    add #(.N(8)) Adder_x(.x(x_old), .y(vx_e), .c_in(1'b0), .ow(ow_x), .s(ris_x));
    assign x_new = ow_x ? x_old : ris_x;

    wire ow_y;
    wire[7:0] ris_y;

    add #(.N(8)) Adder_y(.x(y_old), .y(vy_e), .c_in(1'b0), .ow(ow_y), .s(ris_y));
    assign y_new = ow_y ? y_old : ris_y;
endmodule