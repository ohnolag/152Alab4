`timescale 1ns / 1ps

module slotFSM(
    input  wire clk,
    input  wire rst,
    input  wire spin_request,
    input  wire stop_tick,
    output reg  spinning,
    output reg  reel1_enable,
    output reg  reel2_enable,
    output reg  reel3_enable,
    output reg  reels_stopped
);

    localparam IDLE        = 3'd0;
    localparam SPIN_ALL    = 3'd1;
    localparam STOP_REEL_1 = 3'd2;
    localparam STOP_REEL_2 = 3'd3;
    localparam RESULT      = 3'd4;

    reg [2:0] state = IDLE;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (spin_request)
                        state <= SPIN_ALL;
                end

                SPIN_ALL: begin
                    if (stop_tick)
                        state <= STOP_REEL_1;
                end

                STOP_REEL_1: begin
                    if (stop_tick)
                        state <= STOP_REEL_2;
                end

                STOP_REEL_2: begin
                    if (stop_tick)
                        state <= RESULT;
                end

                RESULT: begin
                    if (spin_request)
                        state <= SPIN_ALL;
                    else
                        state <= RESULT;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        spinning = 1'b0;
        reel1_enable = 1'b0;
        reel2_enable = 1'b0;
        reel3_enable = 1'b0;
        reels_stopped = 1'b0;

        case (state)
            IDLE: begin
                spinning = 1'b0;
            end

            SPIN_ALL: begin
                spinning = 1'b1;
                reel1_enable = 1'b1;
                reel2_enable = 1'b1;
                reel3_enable = 1'b1;
            end

            STOP_REEL_1: begin
                spinning = 1'b1;
                reel2_enable = 1'b1;
                reel3_enable = 1'b1;
            end

            STOP_REEL_2: begin
                spinning = 1'b1;
                reel3_enable = 1'b1;
            end

            RESULT: begin
                reels_stopped = 1'b1;
            end
        endcase
    end

endmodule
