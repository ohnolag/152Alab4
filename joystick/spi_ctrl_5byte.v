`timescale 1ns / 1ps

module spi_ctrl_5byte(
    input  wire        clk,
    input  wire        rst,
    input  wire        snd_rec,
    input  wire        byte_busy,
    input  wire [7:0]  din,
    input  wire [7:0]  rx_data,

    output reg         ss,
    output reg         get_byte,
    output reg  [7:0]  snd_data,
    output reg  [39:0] dout,
    output reg         data_ready
);

    localparam IDLE  = 3'd0;
    localparam INIT  = 3'd1;
    localparam WAIT  = 3'd2;
    localparam CHECK = 3'd3;
    localparam DONE  = 3'd4;

    reg [2:0] state = IDLE;
    reg [2:0] byte_count = 3'd0;
    reg [39:0] tmp_shift = 40'd0;

    always @(negedge clk) begin
        if (rst) begin
            ss <= 1'b1;
            get_byte <= 1'b0;
            snd_data <= 8'd0;
            dout <= 40'd0;
            data_ready <= 1'b0;
            tmp_shift <= 40'd0;
            byte_count <= 3'd0;
            state <= IDLE;
        end else begin
            data_ready <= 1'b0;

            case (state)
                IDLE: begin
                    ss <= 1'b1;
                    get_byte <= 1'b0;
                    snd_data <= 8'd0;
                    tmp_shift <= 40'd0;
                    byte_count <= 3'd0;

                    if (snd_rec)
                        state <= INIT;
                end

                INIT: begin
                    ss <= 1'b0;
                    get_byte <= 1'b1;

                    if (byte_count == 3'd0)
                        snd_data <= din;
                    else
                        snd_data <= 8'd0;

                    if (byte_busy) begin
                        byte_count <= byte_count + 1'b1;
                        state <= WAIT;
                    end
                end

                WAIT: begin
                    ss <= 1'b0;
                    get_byte <= 1'b0;

                    if (!byte_busy)
                        state <= CHECK;
                end

                CHECK: begin
                    ss <= 1'b0;
                    get_byte <= 1'b0;
                    tmp_shift <= {tmp_shift[31:0], rx_data};

                    if (byte_count == 3'd5)
                        state <= DONE;
                    else
                        state <= INIT;
                end

                DONE: begin
                    ss <= 1'b1;
                    get_byte <= 1'b0;
                    snd_data <= 8'd0;
                    dout <= tmp_shift;
                    data_ready <= 1'b1;

                    if (!snd_rec)
                        state <= IDLE;
                end
            endcase
        end
    end

endmodule