//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           ov5640_rgb565_lcd
// Last modified Date:  2018/11/2 13:58:23
// Last Version:        V1.0
// Descriptions:        OV5640 摄像头RGB TFT-LCD显示实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/21 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov5640_rgb565_lcd(    
    input         sys_clk    ,  //系统时钟
    input         sys_rst_n  ,  //系统复位，低电平有效
    //摄像头0 
    input         cam0_pclk  ,  //cmos 数据像素时钟
    input         cam0_vsync ,  //cmos 场同步信号
    input         cam0_href  ,  //cmos 行同步信号
    input  [7:0]  cam0_data  ,  //cmos 数据  
    output        cam0_rst_n ,  //cmos 复位信号，低电平有效
    output        cam0_pwdn  ,  //cmos 电源休眠模式选择信号
    output        cam0_scl   ,  //cmos SCCB_SCL线
    inout         cam0_sda   ,  //cmos SCCB_SDA线
    
    //摄像头1 
    input         cam1_pclk  ,  //cmos 数据像素时钟
    input         cam1_vsync ,  //cmos 场同步信号
    input         cam1_href  ,  //cmos 行同步信号
    input  [7:0]  cam1_data  ,  //cmos 数据  
    output        cam1_rst_n ,  //cmos 复位信号，低电平有效
    output        cam1_pwdn  ,  //cmos 电源休眠模式选择信号
    output        cam1_scl   ,  //cmos SCCB_SCL线
    inout         cam1_sda   ,  //cmos SCCB_SDA线    
    //SDRAM 
    output        sdram_clk  ,  //SDRAM 时钟
    output        sdram_cke  ,  //SDRAM 时钟有效
    output        sdram_cs_n ,  //SDRAM 片选
    output        sdram_ras_n,  //SDRAM 行有效
    output        sdram_cas_n,  //SDRAM 列有效
    output        sdram_we_n ,  //SDRAM 写有效
    output [1:0]  sdram_ba   ,  //SDRAM Bank地址
    output [1:0]  sdram_dqm  ,  //SDRAM 数据掩码
    output [12:0] sdram_addr ,  //SDRAM 地址
    inout  [15:0] sdram_data ,  //SDRAM 数据    
    //LCD                   
    output        lcd_hs     ,  //LCD 行同步信号
    output        lcd_vs     ,  //LCD 场同步信号
    output        lcd_de     ,  //LCD 数据输入使能
    inout  [15:0] lcd_rgb    ,  //LCD RGB565颜色数据
    output        lcd_bl     ,  //LCD 背光控制信号
    output        lcd_rst    ,  //LCD 复位信号
    output        lcd_pclk      //LCD 采样时钟
    );

//wire define
wire        clk_100m       ;  //100mhz时钟,SDRAM操作时钟
wire        clk_100m_shift ;  //100mhz时钟,SDRAM相位偏移时钟
wire        clk_100m_lcd   ;  //100mhz时钟,LCD顶层模块时钟
wire        clk_lcd        ;  
wire        locked         ;
wire        rst_n          ;
wire        sys_init_done  ;  //系统初始化完成(sdram初始化+摄像头初始化)
                    
wire        cam0_init_done ;
wire        cam1_init_done ;
                    
wire        wr0_en         ;  //sdram_ctrl模块写使能
wire [15:0] wr0_data       ;  //sdram_ctrl模块写数据
wire        wr1_en         ;  //sdram_ctrl模块写使能
wire [15:0] wr1_data       ;  //sdram_ctrl模块写数据
wire        rd_en          ;  //sdram_ctrl模块读使能
wire [15:0] rd_data        ;  //sdram_ctrl模块读数据
wire        sdram_init_done;  //SDRAM初始化完成

wire [15:0] ID_lcd         ;  //LCD的ID

wire [12:0] cmos_h_pixel   ;  //CMOS水平方向像素个数 
wire [12:0] cmos_v_pixel   ;  //CMOS垂直方向像素个数
wire [12:0] total_h_pixel  ;  //水平总像素大小
wire [12:0] total_v_pixel  ;  //垂直总像素大小
wire [23:0] sdram_max_addr ;  //sdram读写的最大地址

//*****************************************************
//**                    main code
//*****************************************************

assign  rst_n = sys_rst_n & locked;
//系统初始化完成：SDRAM和摄像头都初始化完成
//避免了在SDRAM初始化过程中向里面写入数据
assign  sys_init_done = sdram_init_done & cam0_init_done & cam1_init_done;

//锁相环
pll u_pll(
    .areset             (~sys_rst_n),
    .inclk0             (sys_clk),
            
    .c0                 (clk_100m),
    .c1                 (clk_100m_shift),
    .c2                 (clk_100m_lcd),
    .locked             (locked)
    );

//例化LCD顶层模块
lcd u_lcd(
    .clk                (clk_100m_lcd),
    .rst_n              (rst_n),
                        
    .lcd_hs             (lcd_hs),
    .lcd_vs             (lcd_vs),
    .lcd_de             (lcd_de),
    .lcd_rgb            (lcd_rgb),
    .lcd_bl             (lcd_bl),
    .lcd_rst            (lcd_rst),
    .lcd_pclk           (lcd_pclk),
            
    .pixel_data         (rd_data),
    .rd_en              (rd_en),
    .clk_lcd            (clk_lcd),          //LCD驱动时钟

    .ID_lcd             (ID_lcd)            //LCD ID
    );
    
//摄像头图像分辨率设置模块
picture_size u_picture_size (
    .rst_n              (rst_n),

    .ID_lcd             (ID_lcd),           //LCD的ID，用于配置摄像头的图像大小
                        
    .cmos_h_pixel       (cmos_h_pixel  ),   //摄像头水平方向分辨率 
    .cmos_v_pixel       (cmos_v_pixel  ),   //摄像头垂直方向分辨率  
    .total_h_pixel      (total_h_pixel ),   //用于配置HTS寄存器
    .total_v_pixel      (total_v_pixel ),   //用于配置VTS寄存器
    .sdram_max_addr     (sdram_max_addr)    //sdram读写的最大地址
    );  

//OV5640 0摄像头驱动
ov5640_dri u0_ov5640_dri(
    .clk               (clk_100m_lcd),
    .rst_n             (rst_n),

    .cam_pclk          (cam0_pclk ),
    .cam_vsync         (cam0_vsync),
    .cam_href          (cam0_href ),
    .cam_data          (cam0_data ),
    .cam_rst_n         (cam0_rst_n),
    .cam_pwdn          (cam0_pwdn ),
    .cam_scl           (cam0_scl  ),
    .cam_sda           (cam0_sda  ),
    
    .capture_start     (sys_init_done),
    .cmos_h_pixel      (cmos_h_pixel[12:1]),
    .cmos_v_pixel      (cmos_v_pixel),
    .total_h_pixel     (total_h_pixel),
    .total_v_pixel     (total_v_pixel),
    .cam_init_done     (cam0_init_done),

    .cmos_frame_vsync  (),
    .cmos_frame_href   (),
    .cmos_frame_valid  (wr0_en),
    .cmos_frame_data   (wr0_data)
    );
    
//OV5640 1摄像头驱动
ov5640_dri u1_ov5640_dri(
    .clk               (clk_100m_lcd),
    .rst_n             (rst_n),

    .cam_pclk          (cam1_pclk ),
    .cam_vsync         (cam1_vsync),
    .cam_href          (cam1_href ),
    .cam_data          (cam1_data ),
    .cam_rst_n         (cam1_rst_n),
    .cam_pwdn          (cam1_pwdn ),
    .cam_scl           (cam1_scl  ),
    .cam_sda           (cam1_sda  ),
    
    .capture_start     (sys_init_done),
    .cmos_h_pixel      (cmos_h_pixel[12:1]),
    .cmos_v_pixel      (cmos_v_pixel),
    .total_h_pixel     (total_h_pixel),
    .total_v_pixel     (total_v_pixel),
    .cam_init_done     (cam1_init_done),

    .cmos_frame_vsync  (),
    .cmos_frame_href   (),
    .cmos_frame_valid  (wr1_en),
    .cmos_frame_data   (wr1_data)
    );    

// reg      wr2_en = 0;
// reg  [15:0]  wr2_data = 0;cmos_frame_href

// always @( posedge cam1_pclk) begin
    // if(wr1_en) begin
        // wr2_en <= 1'b1;
        // wr2_data <= wr2_data + 1;
    // end
    // else begin
        // wr2_en <= 1'b0;
        // wr2_data <= wr2_data;    
    // end
// end
    
    
//SDRAM 控制器顶层模块,封装成FIFO接口
//SDRAM 控制器地址组成: {bank_addr[1:0],row_addr[12:0],col_addr[8:0]}
sdram_top u_sdram_top(
    .ref_clk            (clk_100m),         //sdram 控制器参考时钟
    .out_clk            (clk_100m_shift),   //用于输出的相位偏移时钟
    .rst_n              (rst_n),            //系统复位
                                            
    //用户写端口    
    .wr_len             (10'd512),          //写SDRAM时的数据突发长度
    .wr_load            (~rst_n),           //写端口复位: 复位写地址,清空写FIFO    
    .wr_min_addr        (24'd0),            //写SDRAM的起始地址
    .wr_max_addr        (sdram_max_addr),   //写SDRAM的结束地址
    
    .wr0_clk            (cam0_pclk),        //写端口FIFO: 写时钟
    .wr0_en             (wr0_en),           //写端口FIFO: 写使能
    .wr0_data           (wr0_data),         //写端口FIFO: 写数据

    .wr1_clk            (cam1_pclk),        //写端口FIFO: 写时钟
    .wr1_en             (wr1_en),           //写端口FIFO: 写使能
    .wr1_data           (wr1_data),         //写端口FIFO: 写数据
    
    //用户读端口                              
    .rd_clk             (clk_lcd),          //读端口FIFO: 读时钟
    .rd_en              (rd_en),            //读端口FIFO: 读使能
    .rd_data            (rd_data),          //读端口FIFO: 读数据
    .rd_min_addr        (24'd0),            //读SDRAM的起始地址
    .rd_max_addr        (sdram_max_addr),   //读SDRAM的结束地址
    .rd_len             (10'd512),          //从SDRAM中读数据时的突发长度
    .rd_load            (~rst_n),           //读端口复位: 复位读地址,清空读FIFO
    .rd_h_pixel         (cmos_h_pixel),    
    
    //用户控制端口                                
    .sdram_read_valid   (1'b1),             //SDRAM 读使能
    .sdram_pingpang_en  (1'b1),             //SDRAM 乒乓操作使能
    .sdram_init_done    (sdram_init_done),  //SDRAM 初始化完成标志
                                            
    //SDRAM 芯片接口                                
    .sdram_clk          (sdram_clk),        //SDRAM 芯片时钟
    .sdram_cke          (sdram_cke),        //SDRAM 时钟有效
    .sdram_cs_n         (sdram_cs_n),       //SDRAM 片选
    .sdram_ras_n        (sdram_ras_n),      //SDRAM 行有效
    .sdram_cas_n        (sdram_cas_n),      //SDRAM 列有效
    .sdram_we_n         (sdram_we_n),       //SDRAM 写有效
    .sdram_ba           (sdram_ba),         //SDRAM Bank地址
    .sdram_addr         (sdram_addr),       //SDRAM 行/列地址
    .sdram_data         (sdram_data),       //SDRAM 数据
    .sdram_dqm          (sdram_dqm)         //SDRAM 数据掩码
    );

endmodule 