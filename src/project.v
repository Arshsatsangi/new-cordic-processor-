`default_nettype none
`timescale 1ns / 1ps

module tt_um_cordic_processor (
    input  wire [7:0] ui_in,    // Dedicated inputs: 8-bit Angle Data Byte
    output wire [7:0] uo_out,   // Dedicated outputs: 8-bit Result Byte (Cos/Sin)
    input  wire [7:0] uio_in,   // IOs: Input path (Control signals)
    output wire [7:0] uio_out,  // IOs: Output path (uio_out[7] = done)
    output wire [7:0] uio_oe,   // IOs: Enable path (1=Output, 0=Input)
    input  wire       ena,      // Always 1 when design is powered
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset
);

    // uio_in[1:0] : Byte Select (00=Byte0 [7:0], 01=Byte1 [15:8], 10=Byte2 [23:16], 11=Byte3 [31:24])
    // uio_in[2]   : Write Enable (1 = write ui_in into selected byte of angle_reg)
    // uio_in[3]   : Start Pulse (1 = trigger 16-cycle CORDIC calculation)
    // uio_in[4]   : Output Select (0 = read cos_out, 1 = read sin_out)
    // uio_out[7]  : Done Flag (1 = outputs valid)

    assign uio_oe = 8'b1000_0000; // uio[7] is output, uio[6:0] are inputs

    wire [1:0] byte_sel = uio_in[1:0];
    wire       we       = uio_in[2];
    wire       start    = uio_in[3];
    wire       out_sel  = uio_in[4];

    reg  signed [31:0] angle_reg;
    wire signed [31:0] cos_out;
    wire signed [31:0] sin_out;
    wire               done;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            angle_reg <= 32'sd0;
        end else if (we) begin
            case (byte_sel)
                2'b00: angle_reg[7:0]   <= ui_in;
                2'b01: angle_reg[15:8]  <= ui_in;
                2'b10: angle_reg[23:16] <= ui_in;
                2'b11: angle_reg[31:24] <= ui_in;
            endcase
        end
    end

    cordic_core u_cordic (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .angle_in (angle_reg),
        .done     (done),
        .cos_out  (cos_out),
        .sin_out  (sin_out)
    );

    wire [31:0] selected_word = out_sel ? sin_out : cos_out;
    reg  [7:0]  out_byte;

    always @(*) begin
        case (byte_sel)
            2'b00: out_byte = selected_word[7:0];
            2'b01: out_byte = selected_word[15:8];
            2'b10: out_byte = selected_word[23:16];
            2'b11: out_byte = selected_word[31:24];
        endcase
    end

    assign uo_out  = out_byte;
    assign uio_out = {done, 7'b000_0000};

    // List unused inputs to avoid lint warnings
    wire _unused = &{ena, uio_in[7:5], 1'b0};

endmodule
