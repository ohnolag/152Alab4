`timescale 1ns / 1ps

// Top-level for the final Lab 4 slot machine.
// Scoring/rubric behavior:
//   - PMOD joystick Y-axis movement starts a round.
//   - Three reel counters cycle 0-9 while enabled.
//   - The FSM stops reel 1, reel 2, and reel 3 one-by-one.
//   - winLogic asserts LED14 for a three-of-a-kind win and LED13 for loss.
//   - btnC resets the whole game back to idle.
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
    wire tick1Hz;
    wire tick50Hz;

    // Joystick signals from joystick/pmod_jstk_driver.v.
    wire joystick_poll;
    wire [9:0] joystick_y_pos;
    wire joystick_pulled_down;
    wire joystick_pulled_up;
    wire spin_request;

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

    assign joystick_pulled_down = joystick_y_pos < 10'd337;
    assign joystick_pulled_up = joystick_y_pos > 10'd687;
    assign spin_request = joystick_pulled_down || joystick_pulled_up;

    clock timing(
        .clk(clk),
        .clk1Hz(tick1Hz),
        .clk50Hz(tick50Hz)
    );

    joystick_poll_timer joystick_timer(
        .clk(clk),
        .rst(rst),
        .poll_pulse(joystick_poll)
    );

    pmod_jstk_driver joystick(
        .clk(clk),
        .rst(rst),
        .poll(joystick_poll),
        .led_ctrl(8'h00),
        .miso(jstk_miso),
        .ss(jstk_ss),
        .sclk(jstk_sclk),
        .mosi(jstk_mosi),
        .raw_data(),
        .x_pos(),
        .y_pos(joystick_y_pos),
        .btn_jstk(),
        .btn_1(),
        .btn_2(),
        .joystick_start(),
        .data_ready()
    );

    slotFSM game_fsm(
        .clk(clk),
        .rst(rst),
        .spin_request(spin_request),
        .stop_tick(tick1Hz),
        .spinning(spinning),
        .reel1_enable(reel1_enable),
        .reel2_enable(reel2_enable),
        .reel3_enable(reel3_enable),
        .reels_stopped(reels_stopped)
    );

    reelCounter #(.START_VALUE(4'd1), .STEP(4'd1)) reel_one(
        .clk(clk),
        .rst(rst),
        .tick(tick50Hz),
        .enable(reel1_enable),
        .value(reel1)
    );

    reelCounter #(.START_VALUE(4'd3), .STEP(4'd3)) reel_two(
        .clk(clk),
        .rst(rst),
        .tick(tick50Hz),
        .enable(reel2_enable),
        .value(reel2)
    );

    reelCounter #(.START_VALUE(4'd7), .STEP(4'd7)) reel_three(
        .clk(clk),
        .rst(rst),
        .tick(tick50Hz),
        .enable(reel3_enable),
        .value(reel3)
    );

    // Existing win/loss comparison module.
    winLogic result_logic(
        .reel1(reel1),
        .reel2(reel2),
        .reel3(reel3),
        .reels_stopped(reels_stopped),
        .win_led(win_led),
        .lose_led(lose_led)
    );

    sevenSegMux display(
        .clk(clk),
        .rst(rst),
        .digit0(reel1),
        .digit1(reel2),
        .digit2(reel3),
        .digit3(4'hF),
        .seg(seg),
        .an(an)
    );

    // LED assignment for demo/rubric:
    // led[11] is on while the reels are spinning/stopping.
    // led[13] turns on after the reels stop if the player loses.
    // led[14] turns on after the reels stop if the player wins.
    assign led[0] = 1'b0;
    assign led[1] = 1'b0;
    assign led[2] = 1'b0;
    assign led[3] = 1'b0;
    assign led[4] = 1'b0;
    assign led[5] = 1'b0;
    assign led[6] = 1'b0;
    assign led[7] = 1'b0;
    assign led[8] = 1'b0;
    assign led[9] = 1'b0;
    assign led[10] = 1'b0;
    assign led[11] = spinning;
    assign led[12] = 1'b0;
    assign led[13] = lose_led;
    assign led[14] = win_led;
    assign led[15] = 1'b0;

endmodule
