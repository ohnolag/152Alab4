`timescale 1ns / 1ps

module top_joystick_test(
    input  wire clk,
    input  wire btnC,

    input  wire jstk_miso,
    output wire jstk_ss,
    output wire jstk_sclk,
    output wire jstk_mosi,

    output wire [15:0] led
);

    localparam [9:0] Y_CENTER = 10'd512;
    localparam [9:0] Y_DEADZONE = 10'd175;

    wire poll;
    wire [39:0] raw_data;
    wire [9:0] x_pos;
    wire [9:0] y_pos;
    wire btn_jstk;
    wire btn_1;
    wire btn_2;
    wire joystick_start;
    wire data_ready;

    reg [22:0] heartbeat_count = 23'd0;
    reg [23:0] ready_count = 24'd0;

    wire pulled_down = y_pos < (Y_CENTER - Y_DEADZONE);
    wire pulled_up = y_pos > (Y_CENTER + Y_DEADZONE);
    wire centered = !pulled_down && !pulled_up;

    always @(posedge clk) begin
        if (btnC) begin
            heartbeat_count <= 23'd0;
            ready_count <= 24'd0;
        end else begin
            heartbeat_count <= heartbeat_count + 1'b1;

            if (data_ready)
                ready_count <= 24'd10_000_000;
            else if (ready_count != 24'd0)
                ready_count <= ready_count - 1'b1;
        end
    end

    joystick_poll_timer poller(
        .clk(clk),
        .rst(btnC),
        .poll_pulse(poll)
    );

    pmod_jstk_driver joystick(
        .clk(clk),
        .rst(btnC),
        .poll(poll),
        .led_ctrl(8'h00),

        .miso(jstk_miso),
        .ss(jstk_ss),
        .sclk(jstk_sclk),
        .mosi(jstk_mosi),

        .raw_data(raw_data),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .btn_jstk(btn_jstk),
        .btn_1(btn_1),
        .btn_2(btn_2),
        .joystick_start(joystick_start),
        .data_ready(data_ready)
    );

    assign led[0] = btn_jstk;
    assign led[1] = btn_1;
    assign led[2] = btn_2;
    assign led[3] = 1'b0;
    assign led[4] = 1'b0;
    assign led[5] = pulled_down;
    assign led[6] = pulled_up;
    assign led[7] = centered;

    assign led[10:8] = y_pos[9:7];
    assign led[11] = joystick_start;
    assign led[12] = 1'b0;
    assign led[13] = 1'b0;
    assign led[14] = ready_count != 24'd0;
    assign led[15] = heartbeat_count[22];

endmodule
