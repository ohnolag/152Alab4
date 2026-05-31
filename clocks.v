`timescale 1ns / 1ps

module clock #(
    parameter integer CLK_FREQ_HZ = 100_000_000
) (
    input  wire clk,
    output reg  clk1Hz  = 1'b0,
    output reg  clk2Hz  = 1'b0,
    output reg  clk50Hz = 1'b0
);

    localparam integer COUNT_1HZ  = CLK_FREQ_HZ / 1;
    localparam integer COUNT_2HZ  = CLK_FREQ_HZ / 2;
    localparam integer COUNT_50HZ = CLK_FREQ_HZ / 50;

    reg [31:0] count1  = 32'd0;
    reg [31:0] count2  = 32'd0;
    reg [31:0] count50 = 32'd0;

    always @(posedge clk) begin
        clk1Hz  <= 1'b0;
        clk2Hz  <= 1'b0;
        clk50Hz <= 1'b0;

        if (count1 == COUNT_1HZ - 1) begin
            count1 <= 32'd0;
            clk1Hz <= 1'b1;
        end else begin
            count1 <= count1 + 1'b1;
        end

        if (count2 == COUNT_2HZ - 1) begin
            count2 <= 32'd0;
            clk2Hz <= 1'b1;
        end else begin
            count2 <= count2 + 1'b1;
        end

        if (count50 == COUNT_50HZ - 1) begin
            count50 <= 32'd0;
            clk50Hz <= 1'b1;
        end else begin
            count50 <= count50 + 1'b1;
        end
    end

endmodule
