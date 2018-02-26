//
//  Tool.m
//  ImageToVideoDemo
//
//  Created by 刘哲 on 2018/2/7.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import "Tool.h"

@implementation Tool
+ (void) testMethod_GetCurrentTime
{
    NSDate *date = [NSDate date]; // 获得时间对象
//    NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
//    NSTimeInterval time = [zone secondsFromGMTForDate:date];// 以秒为单位返回当前时间与系统格林尼治时间的差
//    NSDate *nowDate = [date dateByAddingTimeInterval:time];// 然后把差的时间加上,就是当前系统准确的时间
    NSLog(@"------------------------------------------------------------------------------%@",date);
}

@end
