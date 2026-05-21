`timescale 1ns / 1ps

module clk_div_jstk(
    input  wire clk,
    input  wire rst,
    output reg  clk_out
);

    localparam integer HALF_PERIOD_COUNT = 750;
    reg [9:0] count;

    always @(posedge clk) begin
        if (rst) begin
            count <= 10'd0;
            clk_out <= 1'b0;
        end else begin
            if (count == HALF_PERIOD_COUNT - 1) begin
                count <= 10'd0;
                clk_out <= ~clk_out;
            end else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule