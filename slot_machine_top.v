`timescale 1ns / 1ps

// Mock top-level for the final Lab 4 slot machine.
// This file is a wiring plan: it shows the intended project interface and
// which lower-level modules should connect together.
module slot_machine_top(
    input  wire        clk,        // Basys 3 100 MHz clock
    input  wire        btnC,       // reset game

    // PMOD joystick SPI pins.
    input  wire        jstk_miso,
    output wire        jstk_ss,
    output wire        jstk_sclk,
    output wire        jstk_mosi,

    // Basys 3 seven-segment display.
    output wire [6:0]  seg,
    output wire [3:0]  an,

    // Basys 3 LEDs.
    output wire [15:0] led
);

    wire rst = btnC;

    // Timing signals from clocks.v.
    wire clk1Hz;
    wire clk2Hz;
    wire clk50Hz;

    // Joystick signals from joystick/pmod_jstk_driver.v.
    wire joystick_poll;
    wire joystick_start;
    wire joystick_data_ready;
    wire [39:0] joystick_raw_data;
    wire [9:0] joystick_x_pos;
    wire [9:0] joystick_y_pos;
    wire joystick_btn;
    wire joystick_btn_1;
    wire joystick_btn_2;

    // Slot machine state/control signals from slotFSM.v.
    wire spinning;
    wire reel1_enable;
    wire reel2_enable;
    wire reel3_enable;
    wire reels_stopped;

    // Reel values from reelCounter.v.
    wire [3:0] reel1;
    wire [3:0] reel2;
    wire [3:0] reel3;

    // Result signals from winLogic.v.
    wire win_led;
    wire lose_led;
    wire joystick_pulled_down = joystick_y_pos < 10'd337;
    wire joystick_pulled_up = joystick_y_pos > 10'd687;

    // Existing clock divider module.
    // TODO: update clocks.v so the module name/ports match this instance.
    clock timing(
        .clk(clk),
        .clk1Hz(clk1Hz),
        .clk2Hz(clk2Hz),
        .clk50Hz(clk50Hz)
    );

    // TODO: joystick_poll_timer should generate joystick_poll at 100 Hz.
    // joystick_poll_timer joystick_timer(
    //     .clk(clk),
    //     .rst(rst),
    //     .poll_pulse(joystick_poll)
    // );

    // TODO: pmod_jstk_driver should use Y-axis-only movement as the spin input.
    // pmod_jstk_driver joystick(
    //     .clk(clk),
    //     .rst(rst),
    //     .poll(joystick_poll),
    //     .led_ctrl(8'h00),
    //     .miso(jstk_miso),
    //     .ss(jstk_ss),
    //     .sclk(jstk_sclk),
    //     .mosi(jstk_mosi),
    //     .raw_data(joystick_raw_data),
    //     .x_pos(joystick_x_pos),
    //     .y_pos(joystick_y_pos),
    //     .btn_jstk(joystick_btn),
    //     .btn_1(joystick_btn_1),
    //     .btn_2(joystick_btn_2),
    //     .joystick_start(joystick_start),
    //     .data_ready(joystick_data_ready)
    // );

    // TODO: slotFSM controls the game sequence:
    // IDLE -> SPINNING -> STOP_REEL_1 -> STOP_REEL_2 -> STOP_REEL_3
    // -> EVALUATE -> WIN/LOSE.
    // slotFSM game_fsm(
    //     .clk(clk),
    //     .rst(rst),
    //     .spin_request(joystick_start),
    //     .stop_tick(clk1Hz),
    //     .spinning(spinning),
    //     .reel1_enable(reel1_enable),
    //     .reel2_enable(reel2_enable),
    //     .reel3_enable(reel3_enable),
    //     .reels_stopped(reels_stopped)
    // );

    // TODO: instantiate reelCounter three times.
    // reelCounter reel_one(.clk(clk), .rst(rst), .tick(clk50Hz), .enable(reel1_enable), .value(reel1));
    // reelCounter reel_two(.clk(clk), .rst(rst), .tick(clk50Hz), .enable(reel2_enable), .value(reel2));
    // reelCounter reel_three(.clk(clk), .rst(rst), .tick(clk50Hz), .enable(reel3_enable), .value(reel3));

    // Existing win/loss comparison module.
    winLogic result_logic(
        .reel1(reel1),
        .reel2(reel2),
        .reel3(reel3),
        .reels_stopped(reels_stopped),
        .win_led(win_led),
        .lose_led(lose_led)
    );

    // TODO: sevenSegMux should refresh the four display digits.
    // Suggested display:
    //   an[0] = reel1
    //   an[1] = reel2
    //   an[2] = reel3
    //   an[3] = blank or state indicator
    // sevenSegMux display(
    //     .clk(clk),
    //     .rst(rst),
    //     .refresh_tick(clk50Hz),
    //     .digit0(reel1),
    //     .digit1(reel2),
    //     .digit2(reel3),
    //     .digit3(4'hF),
    //     .seg(seg),
    //     .an(an)
    // );

    // LED assignment plan.
    assign led[0] = joystick_btn;
    assign led[1] = joystick_btn_1;
    assign led[2] = joystick_btn_2;
    assign led[3] = 1'b0;
    assign led[4] = 1'b0;
    assign led[5] = joystick_pulled_down;
    assign led[6] = joystick_pulled_up;
    assign led[7] = !joystick_pulled_down && !joystick_pulled_up;
    assign led[8] = reel1_enable;
    assign led[9] = reel2_enable;
    assign led[10] = reel3_enable;
    assign led[11] = spinning;
    assign led[12] = reels_stopped;
    assign led[13] = lose_led;
    assign led[14] = win_led;
    assign led[15] = clk2Hz;                   // heartbeat/status blink

endmodule

/*
File responsibility map:

slot_machine_top.v
    Final root module. Connects clocks, joystick input, game FSM, reel counters,
    win/loss logic, seven-segment display, and LEDs.

clocks.v
    Generates slow timing signals from the Basys 3 100 MHz clock. Use these for
    reel stepping, stop timing, status blinking, and/or display refresh.

winLogic.v
    Compares the three final reel values once reels_stopped is high. Turns on
    win_led if all three match, otherwise turns on lose_led.

slotFSM.v
    New file. Controls the slot machine states: idle, spinning, stopping reels
    one-by-one, evaluating, and waiting for reset.

reelCounter.v
    New file. One reusable counter for a reel. Counts 0-9 while enable is high
    and holds its final value when enable goes low.

sevenSegDecoder.v
    New file. Converts a 4-bit digit value into the 7 segment pattern for 0-9.

sevenSegMux.v
    New file. Rapidly cycles through the Basys 3 display anodes so reel1, reel2,
    and reel3 appear visible at the same time.

joystick/
    Folder for PMOD joystick-only code. Keep the SPI byte module, 5-byte
    joystick transaction controller, poll timer, clock divider, and joystick
    packet decoder here.
*/
