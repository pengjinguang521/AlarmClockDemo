//
//  AlarmClockModel.h
//  AlarmClockDemo
//
//  Created by JGPeng on 16/9/5.
//  Copyright © 2016年 彭金光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#pragma mark - 闹钟对象

#define ClockDateFormatter  @"yyyy-MM-dd HH:mm:ss"//24时计时法

#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])//APPDELEGATE单类

/**
 *  这边信息的存储 暂时考虑使用归档和解归档的方式来处理，当然也可以使用coreData FMDB
 */

@interface AlarmClockModel : NSObject<NSCoding>

@property (nonatomic,strong)NSString * clockTimer;      //定时器执行的时间

@property (nonatomic,strong)NSString * clockTitle;      //定时器标题

@property (nonatomic,strong)NSString * clockDescribe;   //闹钟描述

@property (nonatomic,strong)NSString * clockMusic;      //闹钟音乐

/**
 *  存储闹钟事件
 *
 *  @param clockModel 传入对象
 */
+ (void)SaveAlarmClockWithModel:(AlarmClockModel*)clockModel;


/**
 *  移除闹钟事件
 *
 *  @param timer 事件值类型为 .h定义的  ClockDateFormatter
 */
+ (void)RemoveAlarmClockWithTimer:(NSString *)timer;


/**
 *  获取所有的闹钟事件
 *
 *  @return 返回所有闹钟事件的数组
 */
+ (NSArray*)GetAllAlarmClockEvent;

@end
