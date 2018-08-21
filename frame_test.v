module frame_test
#(
    parameter   P_WB_R = 1.52,
                P_WB_G = 1.52,
                P_WB_B = 1.15
)
(
    input i_clk,
    input i_rst,
    input [7:0] i_color_g,
    input [7:0] i_color_r,
    input [7:0] i_color_b,
    input i_start_frame_flag,
    input i_end_frame_flag,

    output wire [7:0] o_color_r,
    output wire [7:0] o_color_g,
    output wire [7:0] o_color_b   
);

reg [7:0] gs,inverted;
reg [8:0] next_r, next_g, next_b;

always @(posedge i_clk) begin
    // gs <= (i_color_r + i_color_g + i_color_b)/3;
    //invers colors 8'hff - i_color_r
    next_r <= i_color_r*P_WB_R;
    next_g <= i_color_g*P_WB_G;
    next_b <= i_color_b*P_WB_B; 
end

assign o_color_r = next_r>=255?255:next_r;
assign o_color_g = next_g>=255?255:next_g;
assign o_color_b = next_b>=255?255:next_b;


endmodule // frame_testi_r,
