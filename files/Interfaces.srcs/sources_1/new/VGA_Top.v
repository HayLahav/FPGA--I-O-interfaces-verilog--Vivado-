`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tel Aviv University
// Engineer: Hay Lahav
// 
// Create Date: 01/03/2022 04:50:00 PM
// Design Name: 
// Module Name: VGA_Top
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


module VGA_Top(
                input clk,
                input btnC,
                input PS2Clk,
                input PS2Data,
                output [3:0] vgaRed,
                output [3:0] vgaBlue,
                output [3:0] vgaGreen,
                output Hsync,
                output Vsync
               );
    
    wire rstn;
    
    
    //VGA Interface
    reg [11:0] pixel_color_reg;
    //wire [11:0] pixel_color;
    wire [9:0] XCoord;
    wire [9:0] YCoord;
    
    //Ps2 Interface
    wire [7:0] scancode;
    wire keyPressed;
    wire keyReleased;
    wire errorStrobe;
    
    assign rstn = !btnC;

     
    Ps2_Interface Ps2_Interface_inst(
                                        .PS2Clk(PS2Clk),
                                        .rstn(rstn),
                                        .PS2Data(PS2Data),
                                        .scancode(scancode[7:0]),
                                        .keyPressed(keyPressed),
                                        .keyReleased(keyReleased),
                                        .errorStrobe(errorStrobe));

    
    //colors
    always @(*) begin
        
        if (~rstn)
          begin
            pixel_color_reg <= 12'h000;
          end
    
        //If released the color is white
        else if (keyReleased)
          begin
            pixel_color_reg <= 12'hFFF;
          end
                      
        else if (keyPressed)
          begin
            case (scancode)
                8'h70   :   pixel_color_reg <= 12'hAAA; //key = 0 -> Grey
                8'h69   :   pixel_color_reg <= 12'hF00; //key = 1 -> Red
                8'h72   :   pixel_color_reg <= 12'h0F0; //key = 2 -> Green
                8'h7A   :   pixel_color_reg <= 12'h00F; //key = 3 -> Blue
                8'h6B   :   pixel_color_reg <= 12'hF0F; //key = 4 -> Magenta
                8'h73   :   pixel_color_reg <= 12'h0FF; //key = 5 -> Cyan
                8'h74   :   pixel_color_reg <= 12'h808; //key = 6 -> Purple
                8'h6c   :   pixel_color_reg <= 12'h880; //key = 7 -> Olive
                8'h75   :   pixel_color_reg <= 12'hFF0; //key = 8 -> Yellow
                8'h7D   :   pixel_color_reg <= 12'hF80; //key = 9 -> Orange
                default :   pixel_color_reg <= 12'hFFF; // default -> white
                
            endcase                
          end          
    end

        
   
                                          
                                              
    VGA_interface VGA_interface_inst(
                                     .clk(clk),
                                     .rstn(rstn),
                                     .pixel_color(pixel_color_reg),
                                     .XCoord(XCoord[9:0]),
                                     .YCoord(YCoord[9:0]),
                                     .vgaRed(vgaRed[3:0]),
                                     .vgaBlue(vgaBlue[3:0]),
                                     .vgaGreen(vgaGreen[3:0]),
                                     .Hsync(Hsync),
                                     .Vsync(Vsync));
     
                        
endmodule
