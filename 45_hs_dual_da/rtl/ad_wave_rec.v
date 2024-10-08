//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ad_wave_rec
// Last modified Date:  2018/3/14 17:04:35
// Last Version:        V1.0
// Descriptions:        
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/14 17:04:35
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ad_wave_rec(
    input                 clk         ,  //时钟
    input                 rst_n       ,  //复位信号，低电平有效
    
    input         [7:0]   ad_data     ,  //AD输入数据
    //模拟输入电压超出量程标志(本次试验未用到)
    input                 ad_otr      ,  //0:在量程范围 1:超出量程
    output   reg          ad_clk         //AD(AD9280)驱动时钟,最大支持32Mhz时钟
    );

	 
reg ad_clk_tmp ;
reg ad_clk_tmp1 ;
reg ad_clk_tmp2 ;
	 
//*****************************************************
//**                    main code 
//*****************************************************

//时钟分频(2分频,时钟频率为25Mhz),产生AD时钟

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        ad_clk_tmp <= 1'b0;
    else 
        ad_clk_tmp <= ~ad_clk_tmp; 
end    


always @(posedge ad_clk_tmp or negedge rst_n) begin
    if(rst_n == 1'b0)
        ad_clk_tmp1 <= 1'b0;
    else 
        ad_clk_tmp1 <= ~ad_clk_tmp1; 
end    


always @(posedge ad_clk_tmp1 or negedge rst_n) begin
    if(rst_n == 1'b0)
        ad_clk_tmp2 <= 1'b0;
    else 
        ad_clk_tmp2 <= ~ad_clk_tmp2; 
end    


always @(posedge ad_clk_tmp2 or negedge rst_n) begin
    if(rst_n == 1'b0)
        ad_clk <= 1'b0;
    else 
        ad_clk <= ~ad_clk; 
end    

endmodule