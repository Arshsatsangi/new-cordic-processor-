`default_nettype none
`timescale 1ns / 1ps

module cordic_core (
    input  wire                     clk,
    input  wire                     rst_n,      // Active-low reset
    input  wire                     start,      // 1-clock pulse to load angle and start
    input  wire signed [31:0]       angle_in,   // Q2.30 radians (-pi/2 to +pi/2)
    output reg                      done,       // High when 16 rotations complete
    output wire signed [31:0]       cos_out,    // Q2.30 cosine output
    output wire signed [31:0]       sin_out     // Q2.30 sine output
);
    // CORDIC Gain Compensation Constant K = 0.6072529351 in Q2.30
    localparam signed [31:0] K_INIT = 32'h26DD3B6A;

    reg signed [31:0] x_reg;
    reg signed [31:0] y_reg;
    reg signed [31:0] z_reg;
    reg [3:0]         step;
    reg               busy;

    wire signed [31:0] atan_val;
    cordic_atan_lut u_lut (
        .idx  (step),
        .atan (atan_val)
    );

    wire signed [31:0] x_shift = x_reg >>> step;
    wire signed [31:0] y_shift = y_reg >>> step;
    wire              z_neg   = z_reg[31];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_reg <= 32'sd0;
            y_reg <= 32'sd0;
            z_reg <= 32'sd0;
            step  <= 4'd0;
            busy  <= 1'b0;
            done  <= 1'b0;
        end else if (start) begin
            x_reg <= K_INIT;
            y_reg <= 32'sd0;
            z_reg <= angle_in;
            step  <= 4'd0;
            busy  <= 1'b1;
            done  <= 1'b0;
        end else if (busy) begin
            if (z_neg) begin
                x_reg <= x_reg + y_shift;
                y_reg <= y_reg - x_shift;
                z_reg <= z_reg + atan_val;
            end else begin
                x_reg <= x_reg - y_shift;
                y_reg <= y_reg + x_shift;
                z_reg <= z_reg - atan_val;
            end
            step <= step + 4'd1;
            if (step == 4'd15) begin
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end

    assign cos_out = x_reg;
    assign sin_out = y_reg;

endmodule
