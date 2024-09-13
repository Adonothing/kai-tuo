module Video_Image_Processor
(
    input   clk,    //cmos 像素时钟
    input   rst_n,  
    
    //预处理图像数据
    input        per_frame_vsync, //预图像数据列有效信号  
    input        per_frame_href,  //预图像数据行有效信号  
    input        per_frame_clken, //预图像数据输入使能效信号
    input [15:0] per_img_Y, //输入RGB565数据
    
    //处理后的图像数据
    output       post_frame_vsync, //处理后的图像数据列有效信号  
    output       post_frame_href,  //处理后的图像数据行有效信号  
    output       post_frame_clken, //处理后的图像数据输出使能效信号
    output [7:0] post_img_Y        //处理后的灰度数据           
);

//wire define 
wire [7:0] img_y ;
wire       frame_vsync;
wire       frame_hsync;
wire       post_frame_de;

//*****************************************************
//**                    main code
//*****************************************************

rgb2ycbcr u_rgb2ycbcr(
    .clk             (clk),
    .rst_n           (rst_n),
    
    .pre_frame_vsync (per_frame_vsync),
    .pre_frame_hsync (per_frame_href),
    .pre_frame_de    (per_frame_clken),
    .img_red         (per_img_Y[15:11]),
    .img_green       (per_img_Y[10:5]),
    .img_blue        (per_img_Y[4:0]),
    
    .frame_vsync     (frame_vsync),
    .frame_hsync     (frame_hsync),
    .post_frame_de   (post_frame_de),
    .img_y           (img_y),
    .img_cb          (),
    .img_cr          ()
);

//灰度图中值滤波
VIP_Gray_Median_Filter u_VIP_Gray_Median_Filter(
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //预处理图像数据
    .pe_frame_vsync (frame_vsync),
    .pe_frame_href  (frame_hsync),
    .pe_frame_clken (post_frame_de),
    .pe_img_Y       (img_y),
    
    //处理后的图像数据
    .pos_frame_vsync (post_frame_vsync),
    .pos_frame_href  (post_frame_href),
    .pos_frame_clken (post_frame_clken),
    .pos_img_Y       (post_img_Y)
);

endmodule 