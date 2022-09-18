`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tel Aviv University
// Engineer: Hay Lahav
// 
// Create Date: 01/03/2022 03:31:58 PM
// Design Name: 
// Module Name: Ps2_Interface_tb
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


module Ps2_Interface_tb();

    reg clk;
    reg rstn;
    
    reg PS2Data;
    wire PS2Clk;
    wire [7:0] scancode;
    wire keyPressed;
    wire keyReleased;
    wire errorStrobe;
    
    always #0.5 clk = !clk;
       
    initial
        begin
            clk <= 1'b0;
            rstn <= 1'b0;
            PS2Data <= 1'b0;
            #10 rstn <= 1'b1;
            //E0
            CREATE_PS2_IF({1'b1, 1'b0, 8'hE0, 1'b0});
            //key press
            CREATE_PS2_IF({1'b1, 1'b0, 8'h58, 1'b0});
            //key release
            CREATE_PS2_IF({1'b1, 1'b1, 8'hF0, 1'b0});
            CREATE_PS2_IF({1'b1, 1'b0, 8'h58, 1'b0});
            //key press
            CREATE_PS2_IF({1'b1, 1'b0, 8'h1A, 1'b0});
            //key release
            CREATE_PS2_IF({1'b1, 1'b1, 8'hF0, 1'b0});
            CREATE_PS2_IF({1'b1, 1'b0, 8'h1A, 1'b0});
            //error parity
            CREATE_PS2_IF({1'b1, 1'b1, 8'h1A, 1'b0});
            @(posedge clk);
            $stop;
        end
    Ps2_Interface Ps2_Interface_inst(
                                     .PS2Clk(clk),
                                     .rstn(rstn),
                                     .PS2Data(PS2Data),
                                     .scancode(scancode[7:0]),
                                     .keyPressed(keyPressed),
                                     .keyReleased(keyReleased),
                                     .errorStrobe(errorStrobe));
                                     



//---------------------------------------------------------------------------------------------------
//   TASKS
//---------------------------------------------------------------------------------------------------

task CREATE_PS2_IF(input [10:0] data);
    begin
        for (integer i = 0; i < 11; i = i + 1)
            begin
                PS2Data <= data[i];
                @(posedge clk);
            end          
    end 
endtask 

                
endmodule

