`timescale 1ns / 1ps

module joystick_poll_timer #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer POLL_HZ = 100,
    parameter integer PULSE_CYCLES = 10_000
) (
    input  wire clk,
    input  wire rst,
    output reg  poll_pulse
);

    localparam integer COUNT_MAX = CLK_FREQ_HZ / POLL_HZ;
    localparam integer COUNT_WIDTH = $clog2(COUNT_MAX);
    localparam integer PULSE_WIDTH = $clog2(PULSE_CYCLES + 1);

    reg [COUNT_WIDTH-1:0] count = {COUNT_WIDTH{1'b0}};
    reg [PULSE_WIDTH-1:0] pulse_count = {PULSE_WIDTH{1'b0}};

    always @(posedge clk) begin
        if (rst) begin
            count <= {COUNT_WIDTH{1'b0}};
            pulse_count <= {PULSE_WIDTH{1'b0}};
            poll_pulse <= 1'b0;
        end else if (count == COUNT_MAX - 1) begin
            count <= {COUNT_WIDTH{1'b0}};
            pulse_count <= PULSE_CYCLES[PULSE_WIDTH-1:0];
            poll_pulse <= 1'b1;
        end else begin
            count <= count + 1'b1;
            if (pulse_count != {PULSE_WIDTH{1'b0}}) begin
                pulse_count <= pulse_count - 1'b1;
                poll_pulse <= 1'b1;
            end else begin
                poll_pulse <= 1'b0;
            end
        end
    end
endmodule
