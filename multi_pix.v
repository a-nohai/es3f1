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


module multi_pix(
    input clk,
    input n_rst,
    input  wire [23:0] i_vid_data,
    input [3:0] sw,
    input [3:0] btn,
    output [23:0] multi_out
    );
    
reg [23:0] multi_out;

wire [7:0] red;
wire [7:0] blu;
wire [7:0] gre;

assign {red, blu, gre} = i_vid_data;

always@(posedge clk) begin 
    if(!n_rst) begin 
        multi_out <= 0;
    end else begin 
        case(sw)
            4'b0011: 
            begin
            //blur
            end
            4'b0101:
            begin
            //vert sobel
            end
            4'b0111:
            begin
            //horizontal sobel
            end
            4'b1001: 
            begin
            //combined sobel
            end
            default:
                multi_out <= i_vid_data; // Default pass-through
            endcase
            
    end
end

endmodule
