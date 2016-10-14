//
//  ViewController.m
//  AlarmClockDemo
//
//  Created by JGPeng on 16/9/5.
//  Copyright © 2016年 彭金光. All rights reserved.
//

#import "ViewController.h"
#import "AlarmClockModel.h"

@interface ViewController ()

@end

@implementation ViewController

/**
 *  闹钟事件，你需要考虑的是程序运行和程序退出、挂起三种状态
    1、程序运行的时候，你需要保证这个闹钟事件一直在主线程中，并且定时器不能够被释放掉
    2、程序挂起的时候，我们考虑使用本地通知去做，那么定时器就要考虑在在appDelegate执行
    3、程序退出的时候，我们要考虑注册推送信息，用推送来实现
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
#warning - mark 看仔细了 下面代码添加闹钟事件，不用考虑释放问题，已自动处理
    AlarmClockModel * model = [[AlarmClockModel alloc]init];
    model.clockTitle = @"闹钟";
    model.clockDescribe = @"起床了";
    model.clockMusic = @"Thunder Song.m4r";
    model.clockTimer = @"2016-09-06 10:45:00";
    [AlarmClockModel SaveAlarmClockWithModel:model];
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
