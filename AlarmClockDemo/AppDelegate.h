//
//  AppDelegate.h
//  AlarmClockDemo
//
//  Created by JGPeng on 16/9/5.
//  Copyright © 2016年 彭金光. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  这边添加闹钟工具类
 */
#import "AlarmClockTool.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,retain)AlarmClockTool * alarmClockTool;//这边采用appDelegate强引用

@end

