`timescale 1ns / 1ps

module top_joystick_test(
    input  wire clk,        // Basys 3 100 MHz clock
    input  wire btnC,       // reset button

    input  wire jstk_miso,
    output wire jstk_ss,
    output wire jstk_sclk,
    output wire jstk_mosi,

    output wire [15:0] led
);

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

    wire left   = x_pos < 10'd350;
    wire right  = x_pos > 10'd650;
    wire down   = y_pos < 10'd350;
    wire up     = y_pos > 10'd650;
    wire center = (x_pos > 10'd450) && (x_pos < 10'd575) &&
                  (y_pos > 10'd450) && (y_pos < 10'd575);

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

    // Obvious hardware test display.
    assign led[0] = btn_jstk;
    assign led[1] = btn_1;
    assign led[2] = btn_2;
    assign led[3] = left;
    assign led[4] = right;
    assign led[5] = down;
    assign led[6] = up;
    assign led[7] = center;

    // Coarse binary position readout, useful after directions work.
    assign led[10:8] = x_pos[9:7];
    assign led[13:11] = y_pos[9:7];

    assign led[14] = ready_count != 24'd0;
    assign led[15] = heartbeat_count[22];

endmodule
