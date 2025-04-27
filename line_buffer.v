`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: line_buffer
// Description: Delays input data by LINE_WIDTH cycles using inferred RAM.
//              Requires valid enable signal (i_ena).
//////////////////////////////////////////////////////////////////////////////////
module line_buffer #(
    parameter DATA_WIDTH = 24,
    parameter LINE_WIDTH = 1920
) (
    input wire                  clk,
    input wire                  n_rst,
    input wire                  i_ena,
    input wire [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data
);

    localparam ADDR_WIDTH = $clog2(LINE_WIDTH);

    reg [DATA_WIDTH-1:0] buffer [0:LINE_WIDTH-1];
    reg [ADDR_WIDTH-1:0] w_ptr;

    function [ADDR_WIDTH-1:0] read_address (input [ADDR_WIDTH-1:0] write_ptr);
        reg [ADDR_WIDTH-1:0] read_addr;
        begin // Added begin...end block
            if (write_ptr >= LINE_WIDTH) begin
                read_addr = write_ptr - LINE_WIDTH;
            end else begin
                read_addr = write_ptr;
                if (read_addr >= 1)
                    read_addr = read_addr - 1;
                else
                    read_addr = LINE_WIDTH - 1;
            end
        end // Added begin...end block
    endfunction

    always @(posedge clk) begin
        if (!n_rst) begin
            w_ptr <= 0;
            o_data <= 0;
        end else begin
            if (i_ena) begin
                buffer[w_ptr] <= i_data;
                o_data <= buffer[read_address(w_ptr)];
                if (w_ptr == LINE_WIDTH - 1)
                    w_ptr <= 0;
                else
                    w_ptr <= w_ptr + 1;
            end
        end
    end

endmodule
