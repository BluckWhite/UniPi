module ABC(
    soc_vx, eoc_vx, vx,
    soc_vy, eoc_vy, vy,
    x, y, soc_p, eoc_p,
    reset_, clock
);
    input reset_, clock;

    input eoc_vx, eoc_vy;    
    output soc_vx, soc_vy;
    reg SOC; assign soc_vx = SOC, soc_vy = SOC;
    
    input[3:0] vx, vy;
    output[7:0] x, y;
    reg[7:0] X, Y; assign x = X, y = Y;
    
    input soc_p;
    output eoc_p;
    
    reg EOC; assign eoc_p = EOC;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    wire[7:0] x_new, y_new;
    PROSSIMA_POSIZIONE PP(X, Y, vx, vy, x_new, y_new);

    always @(reset_ == 0) begin
        EOC = 1;
        SOC = 0;
        X <= 0;
        Y <= 0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: begin
                EOC <= 1;
                SOC <= 0;
                STAR <= (soc_p == 0) ? S0 : S1;
            end
            S1: begin
                SOC <= 1;
                EOC <= 0;
                STAR <= ({eoc_vx, eoc_vy} == 2'b00) ? S2 : S1;
            end
            S2: begin
                SOC <= 0;
                STAR <= ({eoc_vx, eoc_vy} == 2'b11) ? S3 : S2;
            end
            S3: begin
                X <= x_new;
                Y <= y_new;
                STAR <= (soc_p == 0) ? S0 : S3; 
            end
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