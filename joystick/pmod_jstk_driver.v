`timescale 1ns / 1ps

module pmod_jstk_driver(
    input  wire        clk,
    input  wire        rst,
    input  wire        poll,
    input  wire [7:0]  led_ctrl,

    input  wire        miso,
    output wire        ss,
    output wire        sclk,
    output wire        mosi,

    output wire [39:0] raw_data,
    output wire [9:0]  x_pos,
    output wire [9:0]  y_pos,
    output wire        btn_jstk,
    output wire        btn_1,
    output wire        btn_2,
    output wire        joystick_start,
    output wire        data_ready
);

    wire i_sclk;
    wire get_byte;
    wire byte_busy;
    wire [7:0] snd_data;
    wire [7:0] rx_data;

    clk_div_jstk clock_for_spi(
        .clk(clk),
        .rst(rst),
        .clk_out(i_sclk)
    );

    spi_ctrl_5byte controller(
        .clk(i_sclk),
        .rst(rst),
        .snd_rec(poll),
        .byte_busy(byte_busy),
        .din(led_ctrl),
        .rx_data(rx_data),
        .ss(ss),
        .get_byte(get_byte),
        .snd_data(snd_data),
        .dout(raw_data),
        .data_ready(data_ready)
    );

    spi_mode0 spi_byte_interface(
        .clk(i_sclk),
        .rst(rst),
        .start(get_byte),
        .din(snd_data),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .busy(byte_busy),
        .dout(rx_data)
    );

    assign btn_jstk = raw_data[0];
    assign btn_1    = raw_data[1];
    assign btn_2    = raw_data[2];

    assign x_pos = {raw_data[25:24], raw_data[39:32]};
    assign y_pos = {raw_data[9:8], raw_data[23:16]};

    assign joystick_start =
        btn_jstk |
        btn_1 |
        btn_2 |
        (x_pos > 10'd700) |
        (x_pos < 10'd300) |
        (y_pos > 10'd700) |
        (y_pos < 10'd300);

endmodule