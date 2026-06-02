`timescale 1ns / 1ps

module reelCounter #(
    parameter [3:0] START_VALUE = 4'd0,
    parameter [3:0] STEP = 4'd1
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       tick,
    input  wire       enable,
    output reg  [3:0] value = START_VALUE
);

    wire [4:0] next_value = value + STEP;

    always @(posedge clk) begin
        if (rst) begin
            value <= START_VALUE;
        end else if (enable && tick) begin
            if (next_value >= 5'd10)
                value <= next_value - 5'd10;
            else
                value <= next_value[3:0];
        end
    end

endmodule
