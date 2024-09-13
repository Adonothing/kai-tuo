//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hs_dual_da
// Last modified Date:  2018/3/14 17:04:35
// Last Version:        V1.0
// Descriptions:        高速双路DA实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/14 17:04:35
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_dual_da(
    input                 sys_clk     ,  //系统时钟
    input                 sys_rst_n   ,  //系统复位，低电平有效
    //DA芯片接口
    output                da_clk      ,  //DA(AD9708)驱动时钟,最大支持125Mhz时钟
    output    [9:0]       da_data     ,  //输出给DA的数据

    //DA芯片接口
    output                da_clk1      ,  //DA(AD9708)驱动时钟,最大支持125Mhz时钟
    output    [9:0]       da_data1     //输出给DA的数据	 
);

//wire define 
wire      [9:0]    rd_addr;              //ROM读地址
wire      [9:0]    rd_data;              //ROM读出的数据
//*****************************************************
//**                    main code
//*****************************************************

//assign ad_clk2 = ad_clk ;

assign  da_clk1 = da_clk;
assign  da_data1 = da_data;


pll  u_pll(
	.inclk0 (sys_clk),
	.c0 (clk));

//DA数据发送
da_wave_send u_da_wave_send(
    .clk         (clk), 
    .rst_n       (sys_rst_n),
    .rd_data     (rd_data),
    .rd_addr     (rd_addr),
    .da_clk      (da_clk),  
    .da_data     (da_data)
    );

//ROM存储波形
rom_1024x10b  u_rom_1024x10b(
    .address    (rd_addr),
    .clock      (clk),
    .q          (rd_data)
    );
	 
endmodule