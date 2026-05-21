`timescale 1ns / 1ps

module spi_mode0(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] din,
    input  wire       miso,

    output wire       mosi,
    output wire       sclk,
    output reg        busy,
    output wire [7:0] dout
);

    localparam IDLE = 2'd0;
    localparam INIT = 2'd1;
    localparam RXTX = 2'd2;
    localparam DONE = 2'd3;

    reg [1:0] state = IDLE;
    reg [3:0] bit_count = 4'd0;
    reg [7:0] rx_shift = 8'd0;
    reg [7:0] tx_shift = 8'd0;
    reg clk_enable = 1'b0;

    assign sclk = clk_enable ? clk : 1'b0;
    assign mosi = tx_shift[7];
    assign dout = rx_shift;

    always @(negedge clk) begin
        if (rst) begin
            tx_shift <= 8'd0;
        end else begin
            case (state)
                IDLE: tx_shift <= din;
                RXTX: begin
                    if (clk_enable)
                        tx_shift <= {tx_shift[6:0], 1'b0};
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            rx_shift <= 8'd0;
        end else if (state == RXTX && clk_enable) begin
            rx_shift <= {rx_shift[6:0], miso};
        end
    end

    always @(negedge clk) begin
        if (rst) begin
            state <= IDLE;
            busy <= 1'b0;
            bit_count <= 4'd0;
            clk_enable <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    bit_count <= 4'd0;
                    clk_enable <= 1'b0;

                    if (start)
                        state <= INIT;
                end

                INIT: begin
                    busy <= 1'b1;
                    bit_count <= 4'd0;
                    clk_enable <= 1'b0;
                    state <= RXTX;
                end

                RXTX: begin
                    busy <= 1'b1;
                    bit_count <= bit_count + 1'b1;

                    if (bit_count >= 4'd8)
                        clk_enable <= 1'b0;
                    else
                        clk_enable <= 1'b1;

                    if (bit_count == 4'd8)
                        state <= DONE;
                end

                DONE: begin
                    busy <= 1'b1;
                    bit_count <= 4'd0;
                    clk_enable <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule