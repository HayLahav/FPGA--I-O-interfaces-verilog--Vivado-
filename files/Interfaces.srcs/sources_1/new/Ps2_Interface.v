`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tel Aviv University
// Engineer: Hay Lahav
// 
// Create Date: 01/03/2022 03:27:08 PM
// Design Name: 
// Module Name: Ps2_Interface
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


module Ps2_Interface(
                        input PS2Clk,
                        input rstn,
                        input PS2Data,
                        output reg [7:0] scancode,
                        output reg       keyPressed,
                        output reg       keyReleased,
                        output reg       errorStrobe
                        );
                        
reg [21:0] data_input_sr;
reg [3:0] ps2clk_count;
reg second_data_part;

wire sample_scancode;
wire pairity_check;

assign pairity_check   = ^(data_input_sr[21:13]);
assign sample_scancode = (ps2clk_count == 4'd10) & (data_input_sr[20:13] != 11'hE0) & (data_input_sr[20:13] != 11'hF0) & pairity_check;

always @ (posedge PS2Clk or negedge rstn)//clock counter
    begin
        if (!rstn) 
            ps2clk_count  <= 4'b0;
         else
            begin
                if (ps2clk_count == 4'd10)
                    ps2clk_count  <= 4'b0;
                else 
                    ps2clk_count  <= ps2clk_count + 4'd1;
             end    
     end    

always @ (posedge PS2Clk or negedge rstn)//data stream
    begin
        if (!rstn)
            begin
                data_input_sr <= 22'b0; 
                scancode      <= 8'b0;
            end
         else
            begin
                 data_input_sr[21:0] <= {PS2Data,data_input_sr[21:1]};
                 if (sample_scancode)
                    scancode <= data_input_sr[20:13];
            end    
     end

always @ (posedge PS2Clk or negedge rstn)//output signals
    begin
        if (!rstn)
            begin   
                keyPressed  <= 1'b0;
                keyReleased <= 1'b0;
                errorStrobe <= 1'b0;
                second_data_part <= 1'b0;
             end    
         else
            begin
                if (ps2clk_count != 4'd10)
                    begin
                        keyPressed  <= 1'b0;
                        keyReleased <= 1'b0;
                        errorStrobe <= 1'b0;
                    end 
                else
                    begin
                        if (!pairity_check)
                            begin
                                errorStrobe <= 1'b1;
                                second_data_part <= 1'b0;
                            end 
                        else if (data_input_sr[20:13] == 8'hF0)
                            second_data_part <= 1'b1;
                        else if (data_input_sr[20:13] != 8'hE0)
                            begin
                                if (second_data_part)
                                    begin
                                        keyReleased <= 1'b1;
                                        second_data_part <= 1'b0;
                                    end
                                else
                                    keyPressed <= 1'b1;
                             end
                    end
            end 
    end                                                                            
               
endmodule