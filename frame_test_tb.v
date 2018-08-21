`timescale 1ns/1ns
`include "frame_test.v"


module frame_test_tb();

localparam FILE_SIZE = 750056;//in bytes
localparam source_image = "untitled.bmp";
localparam target_image = "untitled_updated.bmp";

reg [7:0] file_container [0:FILE_SIZE-1];
reg [7:0] file_container_updated [0:FILE_SIZE-1];
integer file_image_size, file_image_position, file_image_width, file_image_height;
integer file_bmp,file_bmp_updated, i, findex;

reg [7:0]   i_color_g;
reg [7:0]  i_color_r;
reg [7:0]  i_color_b;
reg   i_start_frame_flag;
reg   i_end_frame_flag;

wire [7:0]  o_color_r;
wire [7:0]  o_color_g;
wire [7:0]  o_color_b;

reg i_clk, i_rst;
always #(10) i_clk <= ~i_clk;
 
frame_test frame_test_DUT(
    i_clk,
    i_rst,
    i_color_g,
    i_color_r,
    i_color_b,
    i_start_frame_flag,
    i_end_frame_flag,

    o_color_r,
    o_color_g,
    o_color_b
);

always @(posedge i_clk) begin
    if (findex < file_image_size) begin
        i_color_b <= file_container[findex];     
        i_color_g <= file_container[findex+1];
        i_color_r <= file_container[findex+2];
        $display("\t Time %d  \t findex %d \t input RGB \t %h \t output RGB \t%h",$time , findex,{i_color_r,i_color_g,i_color_b}, {o_color_r,o_color_g,o_color_b});
        
        if (findex != 57) begin //57 its a first pixel. o_color_b gets 1'bx data on this step, so skip it.
            $fwriteb(file_bmp_updated,"%c",o_color_b); 
            $fwriteb(file_bmp_updated,"%c",o_color_g); 
            $fwriteb(file_bmp_updated,"%c",o_color_r);          
        end
            
        findex <= findex +3;
    end else begin
        $fwriteb(file_bmp_updated,"%c",o_color_b); 
        $fwriteb(file_bmp_updated,"%c",o_color_g); 
        $fwriteb(file_bmp_updated,"%c",o_color_r);
       

        $fwriteb(file_bmp_updated,"%c",8'h00);// 2bytes with zeros in the end of file.
        $fwriteb(file_bmp_updated,"%c",8'h00);// coz filesize must be divided for 4.

        $fclose(file_bmp_updated);
        $display("FILE %c WRITTEN", target_image);
        $finish();
    end       
end  
        
        

initial begin
    $dumpfile("frame_test_tb.vcd");
    $dumpvars(0, frame_test_tb);

    i_clk = 0;
    i_rst = 0;
    i_start_frame_flag = 0;
    i_end_frame_flag = 0;
    findex = 0;

    file_bmp = $fopen(source_image, "rb");//image need's in correction
    file_bmp_updated = $fopen(target_image, "wb");// ready image with correction

    if (!file_bmp) begin
        $display("Open file %c error!", source_image);
        $finish;
    end else
    if (!file_bmp_updated) begin
        $display("Open file %c error!", target_image);
        $finish;    
    end else begin
        
        i = $fread( file_container,  file_bmp);        
        $fclose(file_bmp);
        $display("--------------------- HEADER DATA ------------------------");

        file_image_size = {file_container[5], file_container[4], file_container[3], file_container[2]};
        $display("\timage size \t %d bytes", file_image_size);

        file_image_position = {file_container[13], file_container[12], file_container[11], file_container[10]};
        $display("\tfirst pixel position \t %hh", file_image_position);

        file_image_width = {file_container[21], file_container[20], file_container[19], file_container[18]};
        $display("\timage width \t %d px", file_image_width);

        file_image_height = {file_container[25], file_container[24], file_container[23], file_container[22]};
        $display("\timage height \t %d px", file_image_height);
        $display("----------------------------------------------------------");

        
       //writing header file
        for (findex = 0; findex < file_image_position ; findex = findex+1 ) begin  
            $fwriteb(file_bmp_updated,"%c",file_container[findex]);          
        end        
      
        findex = file_image_position;//offset, where starts image data by pixels in format bgr (24bits)

        //input data for first clock cycle in module frame_test.v
        i_color_b = file_container[findex];     
        i_color_g = file_container[findex+1];
        i_color_r = file_container[findex+2];            
        findex = findex +3;


    end    

end



endmodule 