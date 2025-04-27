`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 25.04.2025 16:34:04 (Modified: 25.04.2025)
// Design Name:
// Module Name: multi_pix
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Multi-pixel (kernel-based) image processing effects.
//              Requires line buffers to access neighboring pixels.
//
// Dependencies: line_buffer.v
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Added Blur and Sobel implementations
// Additional Comments: Assumes 3x3 kernels. Edge effects are not explicitly handled.
//
//////////////////////////////////////////////////////////////////////////////////

module multi_pix #(

    parameter DATA_WIDTH = 24,
    parameter LINE_WIDTH = 1920 // Set appropriately for your video resolution

) (

    input wire                        clk,
    input wire                        n_rst,
    input wire                        i_vid_VDE, // Need Video Data Enable signal
    input wire [DATA_WIDTH-1:0]       i_vid_data,
    input wire [3:0]                  sw,
    output reg [DATA_WIDTH-1:0]       multi_out

);



    localparam R_MSB = DATA_WIDTH-1;
    localparam R_LSB = DATA_WIDTH-8;
    localparam B_MSB = DATA_WIDTH-9;
    localparam B_LSB = DATA_WIDTH-16;
    localparam G_MSB = DATA_WIDTH-17;
    localparam G_LSB = 0; // Assuming {R, B, G} packing based on colour_change



    // --- Line Buffer Instantiation ---

    wire [DATA_WIDTH-1:0] data_line1; // Data delayed by 1 line
    wire [DATA_WIDTH-1:0] data_line2; // Data delayed by 2 lines

    line_buffer #( .DATA_WIDTH(DATA_WIDTH), .LINE_WIDTH(LINE_WIDTH) ) lb1 (
        .clk    (clk),
        .n_rst  (n_rst),
        .i_ena  (i_vid_VDE), // Use VDE as enable
        .i_data (i_vid_data),
        .o_data (data_line1)
    );



    line_buffer #( .DATA_WIDTH(DATA_WIDTH), .LINE_WIDTH(LINE_WIDTH) ) lb2 (
        .clk    (clk),
        .n_rst  (n_rst),
        .i_ena  (i_vid_VDE), // Use VDE as enable
        .i_data (data_line1), // Feed output of lb1 into lb2
        .o_data (data_line2)
    );


    // --- 3x3 Window Registers ---
    reg [DATA_WIDTH-1:0] pix_0_m1, pix_0_0, pix_0_p1;
    reg [DATA_WIDTH-1:0] pix_1_m1, pix_1_0, pix_1_p1;
    reg [DATA_WIDTH-1:0] pix_2_m1, pix_2_0, pix_2_p1;

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            pix_0_m1 <= 0; pix_0_0 <= 0; pix_0_p1 <= 0;
            pix_1_m1 <= 0; pix_1_0 <= 0; pix_1_p1 <= 0;
            pix_2_m1 <= 0; pix_2_0 <= 0; pix_2_p1 <= 0;

        end else if (i_vid_VDE) begin // Only shift when data is valid
            pix_0_m1 <= i_vid_data;
            pix_0_0  <= pix_0_m1;
            pix_0_p1 <= pix_0_0;

            pix_1_m1 <= data_line1;
            pix_1_0  <= pix_1_m1;
            pix_1_p1 <= pix_1_0;

            pix_2_m1 <= data_line2;
            pix_2_0  <= pix_2_m1;
            pix_2_p1 <= pix_2_0;
        end
    end



    // --- Kernel Processing Logic (as before) ---

    function [7:0] calculate_greyscale (input [7:0] r, input [7:0] g, input [7:0] b);
        begin
            calculate_greyscale = ({2'd0, r} + {2'd0, g} + {2'd0, b}) / 3;
        end
    endfunction

    wire [7:0] r0m1 = pix_0_m1[R_MSB:R_LSB]; wire [7:0] g0m1 = pix_0_m1[G_MSB:G_LSB]; wire [7:0] b0m1 = pix_0_m1[B_MSB:B_LSB];
    wire [7:0] r00  = pix_0_0[R_MSB:R_LSB];  wire [7:0] g00  = pix_0_0[G_MSB:G_LSB];  wire [7:0] b00  = pix_0_0[B_MSB:B_LSB];
    wire [7:0] r0p1 = pix_0_p1[R_MSB:R_LSB]; wire [7:0] g0p1 = pix_0_p1[G_MSB:G_LSB]; wire [7:0] b0p1 = pix_0_p1[B_MSB:B_LSB];
    wire [7:0] r1m1 = pix_1_m1[R_MSB:R_LSB]; wire [7:0] g1m1 = pix_1_m1[G_MSB:G_LSB]; wire [7:0] b1m1 = pix_1_m1[B_MSB:B_LSB];
    wire [7:0] r10  = pix_1_0[R_MSB:R_LSB];  wire [7:0] g10  = pix_1_0[G_MSB:G_LSB];  wire [7:0] b10  = pix_1_0[B_MSB:B_LSB];
    wire [7:0] r1p1 = pix_1_p1[R_MSB:R_LSB]; wire [7:0] g1p1 = pix_1_p1[G_MSB:G_LSB]; wire [7:0] b1p1 = pix_1_p1[B_MSB:B_LSB];
    wire [7:0] r2m1 = pix_2_m1[R_MSB:R_LSB]; wire [7:0] g2m1 = pix_2_m1[G_MSB:G_LSB]; wire [7:0] b2m1 = pix_2_m1[B_MSB:B_LSB];
    wire [7:0] r20  = pix_2_0[R_MSB:R_LSB];  wire [7:0] g20  = pix_2_0[G_MSB:G_LSB];  wire [7:0] b20  = pix_2_0[B_MSB:B_LSB];
    wire [7:0] r2p1 = pix_2_p1[R_MSB:R_LSB]; wire [7:0] g2p1 = pix_2_p1[G_MSB:G_LSB]; wire [7:0] b2p1 = pix_2_p1[B_MSB:B_LSB];

    reg [15:0] blur_r_sum, blur_g_sum, blur_b_sum;
    reg [7:0] blur_r_out, blur_g_out, blur_b_out;

    always @(*) begin
        // --- 1) Weighted sum for R channel ---
        blur_r_sum =
             r0m1          // 1 × top-left
           + (r00  << 1)   // 2 × top-center
           + r0p1          // 1 × top-right
           + (r1m1 << 1)   // 2 × mid-left
           + (r10  << 2)   // 4 × mid-center
           + (r1p1 << 1)   // 2 × mid-right
           + r2m1          // 1 × bot-left
           + (r20  << 1)   // 2 × bot-center
           + r2p1;         // 1 × bot-right

        // --- 2) Same for G channel ---
        blur_g_sum =
             g0m1
           + (g00  << 1)
           + g0p1
           + (g1m1 << 1)
           + (g10  << 2)
           + (g1p1 << 1)
           + g2m1
           + (g20  << 1)
           + g2p1;

        // --- 3) And for B channel ---
        blur_b_sum =
             b0m1
           + (b00  << 1)
           + b0p1
           + (b1m1 << 1)
           + (b10  << 2)
           + (b1p1 << 1)
           + b2m1
           + (b20  << 1)
           + b2p1;

        // --- 4) Divide by 16 with a single shift ---
        blur_r_out = blur_r_sum >> 4;
        blur_g_out = blur_g_sum >> 4;
        blur_b_out = blur_b_sum >> 4;
    end

    reg signed [11:0] Gx, Gy;
    reg [7:0] Gx_abs, Gy_abs, Gx_out, Gy_out;
    reg [8:0] G_mag_sum;
    reg [7:0] G_mag;
    
    wire [7:0] gs0m1 = calculate_greyscale(r0m1, g0m1, b0m1);
    wire [7:0] gs00  = calculate_greyscale(r00,  g00,  b00 );
    wire [7:0] gs0p1 = calculate_greyscale(r0p1, g0p1, b0p1);
    wire [7:0] gs1m1 = calculate_greyscale(r1m1, g1m1, b1m1);
    wire [7:0] gs10  = calculate_greyscale(r10,  g10,  b10 );
    wire [7:0] gs1p1 = calculate_greyscale(r1p1, g1p1, b1p1);
    wire [7:0] gs2m1 = calculate_greyscale(r2m1, g2m1, b2m1);
    wire [7:0] gs20  = calculate_greyscale(r20,  g20,  b20 );
    wire [7:0] gs2p1 = calculate_greyscale(r2p1, g2p1, b2p1);

    always @(*) begin
        Gx = (gs0p1 + 2*gs1p1 + gs2p1) - (gs0m1 + 2*gs1m1 + gs2m1);
        Gy = (gs2m1 + 2*gs20 + gs2p1) - (gs0m1 + 2*gs00 + gs0p1);
        
        Gx_out  <= (Gx > 8'd128) ? 8'hFF:8'h0;
        Gy_out  <= (Gy < 8'd128) ? 8'hFF:8'h0;
        
        Gx_abs = (Gx < 0) ? -Gx[7:0] : Gx[7:0];
        Gy_abs = (Gy < 0) ? -Gy[7:0] : Gy[7:0];

        G_mag_sum = {1'b0, Gx_abs} + {1'b0, Gy_abs};

        if (G_mag_sum > 9'd255) begin
            G_mag = 8'hFF;
        end else begin
            G_mag = 8'h00;
        end
    end

    // Delay VDE by a few clock cycles within multi_pix
    reg delayed_vde_pix1;
    reg delayed_vde_pix2;

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            delayed_vde_pix1 <= 1'b0;
            delayed_vde_pix2 <= 1'b0;
        end else begin
            delayed_vde_pix1 <= i_vid_VDE;
            delayed_vde_pix2 <= delayed_vde_pix1;

        end
    end



    // --- Output Selection with Delayed VDE Gating ---

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            multi_out <= 0;
        end else begin
            if (delayed_vde_pix2) begin // Only output when delayed VDE is high
                case (sw)
                    4'b0011: multi_out <= {blur_r_out, blur_b_out, blur_g_out};
                    4'b0101: multi_out <= {Gy_out, Gy_out, Gy_out};
                    4'b0111: multi_out <= {Gx_out, Gx_out, Gx_out};
                    4'b1001: multi_out <= {G_mag, G_mag, G_mag};
                    default: multi_out <= pix_1_0; // Output delayed center pixel by default
                endcase
            end else begin
                multi_out <= pix_1_0; // Or maintain a default output during blanking
            end
        end
    end

endmodule
