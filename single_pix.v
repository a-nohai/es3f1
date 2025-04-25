`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2025 16:34:04
// Design Name: 
// Module Name: single_pix
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_pix(
    input clk,
    input n_rst,
    input  wire [23:0] i_vid_data,
    input [3:0] sw,
    input [3:0] btn,
    output [23:0] vid_out
    );
    
reg [23:0] vid_out;

wire [7:0] red;
wire [7:0] blu;
wire [7:0] gre;

reg [9:0] newr;
reg [9:0] newb;
reg [9:0] newg;
reg [9:0] greyscale;

assign {red, blu, gre} = i_vid_data;

always@(posedge clk) begin 
    if(!n_rst) begin 
        vid_out <= 0;
    end else begin 
        case(btn)
            4'b0010: //inverted
            begin
                vid_out <= {~red, ~blu, ~gre}; // Use bitwise NOT for inversion
            end
            4'b0100: //greyscale
            begin
               newr <= {2'd0, red};
               newb <= {2'd0, blu};
               newg <= {2'd0, gre};
               greyscale <= (newr + newb + newg) / 3; // Integer division ok here
               vid_out <= {greyscale[7:0], greyscale[7:0], greyscale[7:0]};
            end
            4'b1000: //binary
            begin
               newr <= {2'd0, red};
               newb <= {2'd0, blu};
               newg <= {2'd0, gre};
               greyscale <= (newr + newb + newg) / 3;
               if (greyscale[9:2] < 8'd128) // Check MSBs for thresholding
                    vid_out <= 24'h000000; // Black
               else
                    vid_out <= 24'hFFFFFF; // White
            end
            default:
                vid_out <= i_vid_data; // Default pass-through
            endcase
            
    end
end

endmodule
