`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Alex Bucknall
// 
// Create Date: 19.02.2019 15:33:35
// Design Name: pcam-5c-zybo
// Module Name: colour_change
// Project Name: pcam-5c-zybo
// Target Devices: Zybo Z7 20
// Tool Versions: Vivado 2017.4
// Description: RBG Colour Changing Module (vid_io)
// 
// Dependencies: N/A
// 
// Revision: 0.01
// Revision 0.01 - File Created
// Additional Comments: N/A
// 
//////////////////////////////////////////////////////////////////////////////////


module colour_change #
(
    parameter DATA_WIDTH = 24 // 8 bits for R, G & B
)
(
    input  wire                   clk,
    input  wire                   n_rst,

    /*
     * Pixel inputs
     */
    input  wire [DATA_WIDTH-1:0] i_vid_data,
    input  wire                  i_vid_hsync,
    input  wire                  i_vid_vsync,
    input  wire                  i_vid_VDE,

    /*
     * Pixel output
     */
    output reg [DATA_WIDTH-1:0] o_vid_data,
    output reg                  o_vid_hsync,
    output reg                  o_vid_vsync,
    output reg                  o_vid_VDE,
    
    /*
     * Control
     */
    input wire [3:0]            btn,
    input wire [3:0]            sw
);

wire button0;
wire button1;
wire button2;
wire button3;

wire [7:0] red;
wire [7:0] blu;
wire [7:0] gre;

wire [23:0] vid_out;
wire [23:0] multi_out;

assign {red, blu, gre} = i_vid_data;
assign button0 = btn[0];
assign button1 = btn[1];
assign button2 = btn[2];
assign button3 = btn[3];

always @ (posedge clk) begin
    if(!n_rst) begin
        o_vid_hsync <= 0;
        o_vid_vsync <= 0; 
        o_vid_VDE <= 0;
        o_vid_data <= 0;
    end
    else begin
        o_vid_hsync <= i_vid_hsync;
        o_vid_vsync <= i_vid_vsync; 
        o_vid_VDE <= i_vid_VDE;

        case(sw)
            4'b1100: //red-blue switch
            begin
               if (button0)
                   o_vid_data <= {blu, red, gre};
               else
                   o_vid_data <= i_vid_data; // Source from raw input for non-kernel effects
            end
            4'b1010: //red-green switch
            begin
               if (button0)
                   o_vid_data <= {gre, blu, red};
               else
                   o_vid_data <= i_vid_data; // Source from raw input
            end
            4'b0110: //green-blue switch
            begin
               if (button0)
                   o_vid_data <= {red, gre, blu};
               else
                   o_vid_data <= i_vid_data; // Source from raw input
            end
            4'b0000: // Simple effects
            begin
               if (button1) begin //inverted
                   o_vid_data <= vid_out;
               end else if (button2) begin //greyscale
                   o_vid_data <= vid_out;
               end else if (button3) begin //binary               
                   o_vid_data <= vid_out;
               end else begin
                   o_vid_data <= i_vid_data; // Source from raw input
               end
            end

            // Kernel-based effects source from kernel_output
            4'b0011: o_vid_data <= multi_out; //blur
            4'b0101: o_vid_data <= multi_out; //vert sobel
            4'b0111: o_vid_data <= multi_out; //horizontal sobel
            4'b1001: o_vid_data <= multi_out; //combined sobel
            default:
                o_vid_data <= i_vid_data; // Default pass-through
        endcase
        
    end
end

single_pix singlepix_inst (
    .clk(clk),
    .n_rst(n_rst),
    .i_vid_data(i_vid_data),
    .btn(btn),
    .sw(sw),
    .vid_out(vid_out)
);

multi_pix multiepix_inst (
    .clk(clk),
    .n_rst(n_rst),
    .i_vid_data(i_vid_data),
    .btn(btn),
    .sw(sw),
    .vid_out(vid_out)
);


endmodule
