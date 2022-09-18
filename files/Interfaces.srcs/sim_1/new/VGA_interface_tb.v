`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2022 04:51:29 PM
// Design Name: 
// Module Name: VGA_interface_tb
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


module VGA_interface_tb();

    reg clk;
    reg rstn;
    reg [11:0]  pixel_color;
    wire [3:0]  vgaRed;
    wire [3:0]  vgaGreen;
    wire [3:0]  vgaBlue;
    wire        Hsync;
    wire        Vsync;
    wire[9:0]  XCoord; 
    wire[9:0]  YCoord;
    
    always #0.5 clk = !clk;
       
    initial
        begin
            clk <= 1'b0;
            rstn <= 1'b0;
            pixel_color[11:0] <= $random();
            #10 rstn <= 1'b1;
            @(posedge clk);
            CREATE_SCREEN();
            $display("test finished successfully");
            $stop;
        end
        
    VGA_interface VGA_interface_inst(
                                     .clk(clk),
                                     .rstn(rstn),
                                     .pixel_color(pixel_color[11:0]),
                                     .vgaRed(vgaRed),
                                     .vgaGreen(vgaGreen),
                                     .vgaBlue(vgaBlue),
                                     .Hsync(Hsync),
                                     .Vsync(Vsync),
                                     .XCoord(XCoord),
                                     .YCoord(YCoord));
     initial
        begin
            forever
                CHECK_SYNC();
        end
        
      initial
         begin
             forever
                CHECK_NOT_VISIBLE();
         end
                                        
//---------------------------------------------------------------------------------------------------
//   TASKS
//---------------------------------------------------------------------------------------------------

task CREATE_SCREEN();
    begin
        for (integer i = 0; i < 420000*4; i = i + 1)
            begin
                pixel_color[11:0] <= $random();
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
            end
    end             
endtask

task CHECK_SYNC();
    begin
        if (XCoord >= 10'd659 & XCoord <= 10'd754)
            begin
                if (Hsync)
                    begin
                        $display("problem with Hsync at XCoord value: %d", XCoord);
                        $stop;
                    end
             end 
        else
            begin
                if (!Hsync)
                     begin
                        $display("problem with Hsync at XCoord value: %d", XCoord);
                        $stop;
                     end
            end
        if (YCoord >= 10'd492 & YCoord <= 10'd494)
            begin 
                if (Vsync)
                    begin
                         $display("problem with Vsync at VCoord value: %d", YCoord);
                        $stop;
                    end 
            end
        else
            begin
                 if (!Vsync)
                      begin
                        $display("problem with Vsync at VCoord value: %d", YCoord);
                        $stop;
                      end 
            end
        @(posedge clk);
    end 
endtask 

task CHECK_NOT_VISIBLE();
    begin
        if (XCoord >= 10'd640 & XCoord <= 10'd799)
            if (|{vgaRed, vgaGreen, vgaBlue})
                begin
                  $display("problem with pixel color at XCoord value: %d", XCoord);
                   $stop;
                end
        if (YCoord >= 10'd480 & YCoord <= 10'd525)  
             if (|{vgaRed, vgaGreen, vgaBlue})
                 begin
                     $display("problem with pixel color at YCoord value: %d", YCoord);
                     $stop;
                  end
         @(posedge clk);       
    end 
endtask 

 

        
endmodule
