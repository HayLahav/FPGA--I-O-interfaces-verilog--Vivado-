`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tel Aviv University
// Engineer: Hay Lahav
// 
// Create Date: 01/03/2022 03:37:28 PM
// Design Name: 
// Module Name: Seg_7_Display
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


module Seg_7_Display(

	input [15:0] x,
    input clk,
    input rstn,
    input [2:0] cur_state,
    output reg [6:0] a_to_g,
    output reg [3:0] an,
    output wire dp 
	 );
     
    localparam IDLE = 3'b001;
    localparam ONE_KEY = 3'b010;
    localparam TWO_KEYS = 3'b100; 
           
    wire [1:0] s;	 
    reg [3:0] digit;
    
    reg [19:0] clkdiv;
    assign s = clkdiv[18:17]; 		// clock division - choose 2 bits to encode the current digit index (0,1,2,3)
    assign dp = 1'b0;                            
   //assign dp = (s == 2'b10) ? 0 : 1;           // dot indicator must be lit to the right of the 3rd digit from te right (between seconds and centiseconds)

   always @(posedge clk or negedge rstn)// or posedge clr)
       if (!rstn)
           digit <= 4'b0;
       else
           case(s)
               0:digit <= x[3:0]; // s is 00 -->0 ;  digit gets assigned 4 bit value assigned to x[3:0]
               1:digit <= x[7:4]; // s is 01 -->1 ;  digit gets assigned 4 bit value assigned to x[7:4]
               2:digit <= x[11:8]; // s is 10 -->2 ;  digit gets assigned 4 bit value assigned to x[11:8
               3:digit <= x[15:12]; // s is 11 -->3 ;  digit gets assigned 4 bit value assigned to x[15:12]          
               default:digit <= x[3:0];
           endcase
       
   //decoder or truth-table for 7a_to_g display values
   always @(*)
       case(digit)
           //////////<---MSB-LSB<---/////
           //////////////gfedcba/////////                       a
           0:a_to_g = 7'b1000000;////0000                      __                    
           1:a_to_g = 7'b1111001;////0001                   f/   /b
           2:a_to_g = 7'b0100100;////0010                     g
           //                                                __    
           3:a_to_g = 7'b0110000;////0011                e /   /c
           4:a_to_g = 7'b0011001;////0100                  __
           5:a_to_g = 7'b0010010;////0101                  d  
           6:a_to_g = 7'b0000010;////0110
           7:a_to_g = 7'b1111000;////0111
           8:a_to_g = 7'b0000000;////1000
           9:a_to_g = 7'b0010000;////1001
           'hA:a_to_g = 7'b0001000; // A
           'hB:a_to_g = 7'b0000011; // b
           'hC:a_to_g = 7'b1000110; // C
           'hD:a_to_g = 7'b0100001; // d
           'hE:a_to_g = 7'b0000110; // E
           'hF:a_to_g = 7'b0001110; // F
           default: a_to_g = 7'b0000000; // U
   endcase
   
   // only one anode is lowered to 0 (active low) to choose the digit
   always @(*)begin
       an=4'b1111;
       case(cur_state)
           IDLE:
                an[s]=1'b1;
           ONE_KEY:
                begin
                   if ((s == 2'b0) | (s == 2'b01))
                        an[s] = 1'b0;
                   else
                        an[s] = 1'b1;
                end
           TWO_KEYS:
                an[s] = 1'b0;
           default: an[s] = 1'b1;
       endcase
   end
   
   //clkdiv counter ticking
   always @(posedge clk or negedge rstn) begin
       if (!rstn)
           clkdiv <= 0;
       else
           clkdiv <= clkdiv+1;
   end


endmodule