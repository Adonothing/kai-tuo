//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           hs_dual_ad
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        双路模数转换模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_dual_ad(
    input                 sys_clk     ,  
    //AD0
    input     [9:0]       ad0_data     ,  //AD0数据
    input                 ad0_otr      ,   //输入电压超过量程标志
    output                ad0_clk      ,   //AD0(AD9280)采样时钟
    output                ad0_oe       ,
    //AD1
    input     [9:0]       ad1_data     ,  //AD0数据
    input                 ad1_otr      ,  //输入电压超过量程标志
    output                ad1_clk      ,  //AD1(AD9280)采样时钟  
    output                ad1_oe       
    );
    
 //*****************************************************
//**                    main code
//*****************************************************   
//  ad0_oe=0,正常模式；ad0_oe=1,高阻
wire clk_50m;

assign ad0_oe =  1'b0;
assign ad1_oe =  1'b0;
assign  ad0_clk = ~clk_50m;
assign  ad1_clk = ~clk_50m;


pll u_pll(
	.inclk0 (sys_clk),
	.c0 (clk_50m)
	);


endmodule
