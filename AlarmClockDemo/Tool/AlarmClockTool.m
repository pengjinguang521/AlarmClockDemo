//
//  AlarmClockTool.m
//  AlarmClockDemo
//
//  Created by JGPeng on 16/9/5.
//  Copyright © 2016年 彭金光. All rights reserved.
//

#import "AlarmClockTool.h"
#import <AVFoundation/AVFoundation.h>
#import "AlarmClockModel.h"

#define KNotificationActionIdentifileStar    @"knotificationActionIdentifileStar"
#define KNotificationActionIdentifileComment @"kNotificationActionIdentifileComment"
#define KNotificationCategoryIdentifile      @"KNOtificationCategoryIdentifile"

@interface AlarmClockTool ()<UIAlertViewDelegate>

@property (nonatomic,strong) NSTimer         * timer;//定时器

@property (nonatomic,strong) AlarmClockModel * timerWillPlay;//将要执行的闹钟的时间

@property (nonatomic,assign) NSInteger       count;//定时任务的倒计时值

@property (nonatomic,strong) AVAudioPlayer   * player;//闹钟播放器

@property (nonatomic,strong) UIAlertView     * alert;//弹框


@end

@implementation AlarmClockTool

#pragma mark - 重写set闹钟事件数组的方法

- (void)setAlarmClockArray:(NSArray *)alarmClockArray{
    
    _alarmClockArray = alarmClockArray;
    [self GetAlarmClockModel];
}

/**
 *  获取将要执行任务的对象
 *
 *  @return
 */

- (void)GetAlarmClockModel{
    
    if ([AlarmClockModel GetAllAlarmClockEvent].count == 0) {
        [self.timer invalidate];
        self.timer                  = nil;
    }else{
        NSInteger  willPlayTimer    = 1000000000;
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat        = ClockDateFormatter;
        
        for (AlarmClockModel * model in _alarmClockArray) {
            NSInteger timeCount =
            [[formatter dateFromString:model.clockTimer] timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
            // >0表示定时任务没有被执行
            if (timeCount > 0) {
                if (timeCount < willPlayTimer) {
                    willPlayTimer               = timeCount;
                    self.timerWillPlay          = model;
                    self.count                  = timeCount;
                }
            }
        }
    }
    
    if (_count > 0) {
          self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(TimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }else{
        [self.timer invalidate];
        self.timer = nil;
        
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [_player stop];
}

//定时器任务开始
- (void)TimerAction{
    _count -- ;
    if (_count == 0) {
        //定时任务到了，去获取还有没有其他的定时任务
        [self GetAlarmClockModel];
        //任务到时间了
        
#pragma mark - 当前程序正在执行中的时候会调用
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        //让app支持接受远程控制事件
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        //提示框弹出的同时，开始响闹钟
        self.alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"关闭闹钟" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        self.alert.delegate=self;
        [self.alert show];
        NSString * path=[[NSBundle mainBundle]pathForResource:_timerWillPlay.clockMusic ofType:nil];
        NSURL * url=[NSURL fileURLWithPath:path];
        NSError * error;
        _player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _player.numberOfLoops=-1;    //无限循环  =0 一遍   =1 两遍    =2 三遍     =负数  单曲循环
        _player.volume=2;          //音量
        [_player prepareToPlay];    //准备工作
        [_player play];
        //注册本地通知
        [self addLocalNotification];
        
    }
}

#pragma mark - 需要注册本地通知处理
//
//- (void)registerLocalNotification{
//    //http://blog.csdn.net/songhongri/article/details/39482067  参见
//    //创建消息上面要添加的动作(按钮的形式显示出来)
//    UIMutableUserNotificationAction* action1 = [[UIMutableUserNotificationAction alloc] init];
//    action1.identifier = KNotificationActionIdentifileStar;
//    action1.authenticationRequired = NO;//需要解锁才能处理 if  yes
//    action1.destructive = NO;
//    action1.activationMode = UIUserNotificationActivationModeBackground;//点击后不启动程序，后台处理
//    //按钮的标示
//    action1.title = _timerWillPlay.clockTitle;
//    
//    UIMutableUserNotificationAction* action2 = [[UIMutableUserNotificationAction alloc] init];
//    action2.identifier = KNotificationActionIdentifileComment;
//    action2.title = @"关闭闹钟";
//    action2.authenticationRequired = NO;
//    action2.destructive = NO;
//    action2.activationMode = UIUserNotificationActivationModeBackground;
//    
//    //创建动作(按钮)的类别集合
//    UIMutableUserNotificationCategory * categorys = [[UIMutableUserNotificationCategory alloc] init];
//    categorys.identifier = KNotificationCategoryIdentifile;////这组动作的唯一标示
//    [categorys setActions:@[action1,action2] forContext:UIUserNotificationActionContextDefault];
//    //    创建UIUserNotificationSettings，并设置消息的显示类类型
//    UIUserNotificationSettings* newSetting= [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:[NSSet setWithObject:categorys]];
//    //    注册推送
//    [[UIApplication sharedApplication] registerUserNotificationSettings:newSetting];
//    //程序退出状态
//    if(newSetting.types==UIUserNotificationTypeNone){
//        UIUserNotificationSettings* newSetting= [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:[NSSet setWithObject:categorys]];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:newSetting];
//    }else{
//        //挂起状态
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
//        [self addLocalNotification];
//    }
//}

/**
 *  挂起状态执行本地通知
 */
- (void) addLocalNotification{
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    
    if (notification!=nil) {
        NSDate *now=[NSDate date];
        notification.fireDate=[now dateByAddingTimeInterval:0];//10秒后通知
        notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber += 1; //应用的红色数字+1
#warning mark - 这边需要注意将这个音频文件拖入resource
        notification.soundName = _timerWillPlay.clockMusic;
        notification.alertBody= _timerWillPlay.clockDescribe;//提示信息 弹出提示框
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


//对象释放的方法
- (void)dealloc{
    
    [self.timer invalidate];
    self.timer = nil;
}

@end
