`default_nettype none
`timescale 1ns / 1ps

module cordic_atan_lut (
    input  wire        [3:0]  idx,  // Iteration index 0..15
    output reg  signed [31:0] atan  // atan(2^-idx) in Q2.30 fixed-point
);
    always @(*) begin
        case (idx)
            4'd0 : atan = 32'h3243F6A9; // 0.785398163 rad (45.000 deg)
            4'd1 : atan = 32'h1DAC6705; // 0.463647609 rad (26.565 deg)
            4'd2 : atan = 32'h0FADBAFD; // 0.244978663 rad (14.036 deg)
            4'd3 : atan = 32'h07F56EA7; // 0.124354995 rad ( 7.125 deg)
            4'd4 : atan = 32'h03FEAB77; // 0.062418810 rad ( 3.576 deg)
            4'd5 : atan = 32'h01FFD55C; // 0.031239833 rad ( 1.790 deg)
            4'd6 : atan = 32'h00FFFAAB; // 0.015623729 rad ( 0.895 deg)
            4'd7 : atan = 32'h007FFF55; // 0.007812341 rad ( 0.448 deg)
            4'd8 : atan = 32'h003FFFEB; // 0.003906230 rad ( 0.224 deg)
            4'd9 : atan = 32'h001FFFFD; // 0.001953123 rad ( 0.112 deg)
            4'd10: atan = 32'h00100000; // 0.000976562 rad ( 0.056 deg)
            4'd11: atan = 32'h00080000; // 0.000488281 rad ( 0.028 deg)
            4'd12: atan = 32'h00040000; // 0.000244141 rad ( 0.014 deg)
            4'd13: atan = 32'h00020000; // 0.000122070 rad ( 0.007 deg)
            4'd14: atan = 32'h00010000; // 0.000061035 rad ( 0.003 deg)
            4'd15: atan = 32'h00008000; // 0.000030518 rad ( 0.002 deg)
            default: atan = 32'h00000000;
        endcase
    end
endmodule
