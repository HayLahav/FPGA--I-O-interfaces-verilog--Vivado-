`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tel Aviv University
// Engineer: Hay Lahav
// 
// Create Date: 01/03/2022 03:27:08 PM
// Design Name: 
// Module Name: Ps2_Display
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


module Ps2_Display(
                    input clk,
                    input rstn,
                    input keyPressed,
                    input keyReleased,
                    input errorStrobe,
                    input [7:0] scancode,
                    output [6:0] seg,
                    output [3:0] an,
                    output       dp,
                    output reg [2:0] led
                    );
                    
    localparam IDLE = 3'b001;
    localparam ONE_KEY = 3'b010;
    localparam TWO_KEYS = 3'b100;

    reg [2:0] cur_state;
    reg [2:0] next_state;
                
    reg [15:0] data_to_display;
    //wire [3:0] an_before_mask;
    
    reg keyReleased_d;
    reg [24:0] led_err_cntr;
    reg [24:0] led_prs_cntr;
    reg [24:0] led_rls_cntr;
    
 
                                                                      
    Seg_7_Display Seg_7_Display_inst(
                                     .x(data_to_display[15:0]),
                                     .clk(clk),
                                     .rstn(rstn),
                                     .cur_state(cur_state[2:0]),
                                     .a_to_g(seg[6:0]),
                                     .an(an[3:0]),
                                     .dp(dp));

//--------------------------------------------------------------------------------------------------------------
//  MAIN FSM
//--------------------------------------------------------------------------------------------------------------                                     
    always @ (posedge clk or negedge rstn)//samples current state
        begin
            if (!rstn)
                cur_state <= IDLE;
            else
                cur_state <= next_state;                    
        end 
        
    always @(*)//creates next state
        begin
//            nxt_state <= cur_state;
            next_state = cur_state;
            case (cur_state)
                IDLE:
                    if (keyPressed)
                        next_state = ONE_KEY;
                ONE_KEY:
                    if (keyPressed & (data_to_display[7:0] != scancode))
                        next_state = TWO_KEYS;
                    else if (keyReleased & (data_to_display[7:0] == scancode))
                        next_state = IDLE;
                TWO_KEYS:
                    if (keyReleased)
                        next_state = ONE_KEY;
                default: next_state = IDLE;
            endcase
        end 
     
    always @ (posedge clk or negedge rstn)//data to display on 7 segmant
        begin
            if (!rstn)
                data_to_display <= 16'b0;
            else
                case (cur_state)
                    IDLE:
                        if (keyPressed)
                            data_to_display <= {8'b0, scancode[7:0]};   
                    ONE_KEY: 
                        if (keyPressed & (data_to_display[7:0] != scancode[7:0]))
                            data_to_display[15:8] <= scancode[7:0];
                    TWO_KEYS:
                        if (keyReleased & (scancode[7:0] == data_to_display[7:0]))
                            data_to_display[7:0] <= data_to_display[15:8];
                     default: data_to_display <= 16'b0;
                endcase
         end    
//--------------------------------------------------------------------------------------------------------------
//  LEDS CONTROL
//--------------------------------------------------------------------------------------------------------------     
   always @ (posedge clk or negedge rstn)
       begin
            if (!rstn)
                begin
                    led[2:0] <= 3'b0;
                    led_err_cntr <= 25'b0;
                    led_prs_cntr <= 25'b0;
                    led_rls_cntr <= 25'b0;
                    keyReleased_d <= 1'b0;
                end 
            else
                begin
                    keyReleased_d <= keyReleased;
                    if (keyPressed)
                        begin
                            led[0] <= 1'b1;
                            led_prs_cntr <= 25'd20000000;
                         end
                    else if (|led_prs_cntr)
                        led_prs_cntr <= led_prs_cntr - 25'd1;
                    else
                        led[0] <= 1'b0;
                    if (keyReleased & !keyReleased_d)
                        begin
                            led[1] <= 1'b1;
                            led_rls_cntr <= 25'd20000000;
                        end
                    else if (|led_rls_cntr)
                        led_rls_cntr <= led_rls_cntr - 25'd1;
                    else
                        led[1] <= 1'b0;
                    if (errorStrobe)
                        begin
                            led[2] <= 1'b1;
                            led_err_cntr <= 25'd20000000;
                        end
                    else if (|led_rls_cntr)
                        led_err_cntr <= led_err_cntr - 25'd1;
                    else
                        led[2] <= 1'b0;
               end
       end                        
                                                                                    
endmodule
