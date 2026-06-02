`timescale 1ns / 1ps

module sevenSegMux(
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] digit0,
    input  wire [3:0] digit1,
    input  wire [3:0] digit2,
    input  wire [3:0] digit3,
    output wire [6:0] seg,
    output reg  [3:0] an
);

    reg [15:0] refresh_count = 16'd0;
    reg [1:0]  active_digit = 2'd0;
    reg [3:0]  selected_digit = 4'hF;

    sevenSegDecoder decoder(
        .digit(selected_digit),
        .seg(seg)
    );

    always @(posedge clk) begin
        if (rst) begin
            refresh_count <= 16'd0;
            active_digit <= 2'd0;
        end else begin
            refresh_count <= refresh_count + 1'b1;
            active_digit <= refresh_count[15:14];
        end
    end

    always @(*) begin
        case (active_digit)
            2'd0: begin
                an = 4'b1110;
                selected_digit = digit0;
            end
            2'd1: begin
                an = 4'b1101;
                selected_digit = digit1;
            end
            2'd2: begin
                an = 4'b1011;
                selected_digit = digit2;
            end
            default: begin
                an = 4'b0111;
                selected_digit = digit3;
            end
        endcase
    end

endmodule
