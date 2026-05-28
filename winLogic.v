module winLogic (
    input [3:0] reel1,
    input [3:0] reel2,
    input [3:0] reel3,
    input reels_stopped,

    output reg win_led,
    output reg lose_led
);
    always @(*) begin
        if (reels_stopped) begin
            if ((reel1==reel2) && (reel2==reel3)) begin
                win_led=1;
                lose_led=0;
            end else begin
                win_led=0;
                lose_led=1;
            end
        end else begin
            win_led=0;
            lose_led=0;
        end
    end
endmodule