`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tel Aviv University
// Engineer: Hay Lahav
// 
// Create Date: 01/03/2022 03:27:08 PM
// Design Name: 
// Module Name: Ps2_Top
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


module Ps2_Top(
                input clk,
                input btnC,
                input PS2Clk,
                input PS2Data,
                output [6:0] seg,
                output [3:0] an,
                output dp,
                output [2:0] led
                );
    
    wire rstn;
    wire [7:0] scancode;
    wire keyPressed;
    wire keyReleased;
    wire errorStrobe;
    
    assign rstn     = !btnC;
                 
    Ps2_Interface Ps2_Interface_inst(
                                     .PS2Clk(PS2Clk),
                                     .rstn(rstn),
                                     .PS2Data(PS2Data),
                                     .scancode(scancode[7:0]),
                                     .keyPressed(keyPressed),
                                     .keyReleased(keyReleased),
                                     .errorStrobe(errorStrobe));
    
    Ps2_Display Ps2_Display_inst(
                                 .clk(clk),
                                 .rstn(rstn),
                                 .keyPressed(keyPressed),
                                 .keyReleased(keyReleased),
                                 .errorStrobe(errorStrobe),
                                 .scancode(scancode[7:0]),
                                 .seg(seg[6:0]),
                                 .an(an[3:0]),
                                 .dp(dp),
                                 .led(led[2:0]));
endmodule
