`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2022 04:50:38 PM
// Design Name: 
// Module Name: VGA_interface
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


module VGA_interface(
                     input             clk,
                     input             rstn,
                     input [11:0]      pixel_color,
                     output reg [3:0]  vgaRed,
                     output reg [3:0]  vgaGreen,
                     output reg [3:0]  vgaBlue,
                     output reg        Hsync,
                     output reg        Vsync,
                     output reg [9:0] XCoord, 
                     output reg [9:0] YCoord
                     );
                     
    parameter HSIZE = 800;
    parameter VSIZE = 525;        
    parameter VISIBLE_HSIZE = 640;
    parameter VISIBLE_VSIZE = 480;
    parameter HSYNC_START = 659;
    parameter HSYNC_STOP  = 755;
    parameter VSYNC_START = 492;
    parameter VSYNC_STOP  = 495;
    
    reg [9:0] hcount;
    reg [9:0] vcount;
    reg visible_h;
    reg visible_v;
    reg [1:0] clk_div;
    //reg pxl_clk;
    
    //pixel clock
    always @(posedge clk or negedge rstn)
        begin
            if (!rstn)
              begin
                //pxl_clk <= 1'b0;
                clk_div <= 2'b00;
              end
            else
              begin
                clk_div <= clk_div - 1;
              end
        end
     
    //hcount and vcount            
    always @(posedge clk or negedge rstn)
        begin
            if (!rstn)
                begin
                    hcount <= 10'd0;
                    vcount <= 10'd0;
                end
             else
                begin
                    if (clk_div == 2'b00)
                        begin
                            if (hcount != (HSIZE - 1))
                                hcount <= hcount + 10'd1;
                            else
                                begin
                                    hcount <= 10'b0;
                                    if (vcount != (VSIZE - 1))
                                        vcount <= vcount + 10'd1;
                                    else
                                        vcount <= 10'd0;
                                end   
                         end                             
                 end
         end
    
    //visible h and visible v     
    always @(posedge clk or negedge rstn)
        begin
            if (!rstn)
                begin
                    visible_h <= 1'b1;
                    visible_v <= 1'b1;
                end
            else
                begin
                    if (clk_div == 2'b00)
                        begin
                            if (hcount == (VISIBLE_HSIZE - 1))
                                begin
                                    visible_h <= 1'b0;
                                    if (vcount == VISIBLE_VSIZE - 1)
                                        visible_v <= 1'b0;
                                    else if (vcount == (VSIZE - 1))
                                        visible_v <= 1'b1;   
                                end
                            else if (hcount == (HSIZE - 1))
                                visible_h <= 1'b1;       
                         end          
                end
        end
    
    //colors signals
    always @(posedge clk or negedge rstn)
        begin
            if (!rstn)
                begin
                    vgaRed   <= 4'b0;
                    vgaGreen <= 4'b0;
                    vgaBlue  <= 4'b0;
                end
            else
                begin
                    if (clk_div == 2'b00)
                        begin
                            if (visible_h & visible_v)
                                begin
                                    vgaRed[3:0]   <= pixel_color[11:8];
                                    vgaGreen[3:0] <= pixel_color[7:4];
                                    vgaBlue[3:0]  <= pixel_color[3:0];
                                end
                            else
                                begin
                                    vgaRed[3:0]   <= 4'b0;
                                    vgaGreen[3:0] <= 4'b0;
                                    vgaBlue[3:0]  <= 4'b0;
                                end
                         end
                 end
        end
    
    //hsync and vsync
    always @(posedge clk or negedge rstn)
        begin
            if (!rstn)
                begin
                    Hsync <= 1'b1;
                    Vsync <= 1'b1;
                end
            else
                begin
                    if (clk_div == 2'b00)
                        begin
                            if (hcount == (HSYNC_START))
                                Hsync <= 1'b0;
                            else if (hcount == HSYNC_STOP)
                                Hsync <= 1'b1;
                            if (vcount == VSYNC_START)
                                Vsync <= 1'b0;
                            else if (vcount == VSYNC_STOP)
                                Vsync <= 1'b1;
                         end
                end
        end
    
    //XCoord and YCoord
    always @(posedge clk or negedge rstn)
            begin
                if (!rstn)
                    begin
                        XCoord <= 10'b0;        
                        YCoord <= 10'b0;
                    end
                else
                    begin
                        if (clk_div == 2'b00)
                          begin
                             XCoord <= hcount[9:0];
                             YCoord <= vcount[9:0];
                          end
                    end
            end
                         
endmodule
