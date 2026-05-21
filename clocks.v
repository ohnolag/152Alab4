module clock (
    input clk, //basys master clock 500MHz
    output reg clk1Hz = 0,
    output reg clk2Hz = 0,
    output reg clk50Hz = 0,
);

localparam CLK_FREQ = 100_000_000;
localparam COUNT1 = CLK_FREQ/2;
localparam COUNT2 = CLK_FREQ/4;
localparam COUNT50 = CLK_FREQ/100;

reg [31:0] count1 = 0;
reg [31:0] count2 = 0;
reg [31:0] count50 = 0;

always @(posedge clk) begin
    if (count1 == COUNT1 - 1) begin
        clk1Hz <= ~clk1Hz;
        count1 <= 0;
    end else begin
        count1 <= count1 + 1;
    end

    if (count2 == COUNT2 - 1) begin
        clk2Hz <= ~clk2Hz;
        count2 <= 0;
    end else begin
        count2 <= count2 + 1;
    end

    if (count50 == COUNT50 - 1) begin
        clk50Hz <= ~clk50Hz;
        count50 <= 0;
    end else begin
        count50 <= count50 + 1;
    end


end
    
endmodule