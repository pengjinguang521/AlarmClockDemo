//
//  AlarmClockModel.m
//  AlarmClockDemo
//
//  Created by JGPeng on 16/9/5.
//  Copyright © 2016年 彭金光. All rights reserved.
//

#import "AlarmClockModel.h"

@implementation AlarmClockModel

#pragma mark - 实现NSCoding的代理方法

/**
 *  归档
 *
 *  @param aCoder
 */

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.clockTitle forKey:@"clockTitle"];
    [aCoder encodeObject:self.clockTimer forKey:@"clockTimer"];
    [aCoder encodeObject:self.clockDescribe forKey:@"clockDescribe"];
    [aCoder encodeObject:self.clockMusic forKey:@"clockMusic"];
}

/**
 *  解归档
 *
 *  @param aDecoder
 *
 *  @return
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder{

    if (self == [super init]) {
        self.clockTitle = [aDecoder decodeObjectForKey:@"clockTitle"];
        self.clockTimer = [aDecoder decodeObjectForKey:@"clockTimer"];
        self.clockDescribe = [aDecoder decodeObjectForKey:@"clockDescribe"];
        self.clockMusic = [aDecoder decodeObjectForKey:@"clockMusic"];
    }
    return self;
}

/**
 *  存储闹钟事件
 *
 *  @param clockModel 传入对象
 */
+ (void)SaveAlarmClockWithModel:(AlarmClockModel*)clockModel{
    //存储的话，这边就是归档到本地文件中
    [NSKeyedArchiver archiveRootObject:clockModel toFile:[NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],clockModel.clockTimer]];
    //这边添加一个闹钟的时候需要动态的给闹钟工具类中的数组进行赋值
    if (!APP_DELEGATE.alarmClockTool) {
        APP_DELEGATE.alarmClockTool = [[AlarmClockTool alloc]init];
    }
    //对于单例的闹钟工具进行赋值
    APP_DELEGATE.alarmClockTool.alarmClockArray = [AlarmClockModel GetAllAlarmClockEvent];
}
/**
 *  移除闹钟事件
 *
 *  @param timer 事件值类型为 .h定义的  dateformater
 */
+ (void)RemoveAlarmClockWithTimer:(NSString *)timer{
    //文件路径
    NSString * path = [NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],timer];
    //判断文件是否存在 存在将文件删除
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
        if ([AlarmClockModel GetAllAlarmClockEvent].count > 0) {
            if (!APP_DELEGATE.alarmClockTool) {
                APP_DELEGATE.alarmClockTool = [[AlarmClockTool alloc]init];
            }
            //对于单例的闹钟工具进行赋值
            APP_DELEGATE.alarmClockTool.alarmClockArray = [AlarmClockModel GetAllAlarmClockEvent];
        }else{
            //将appleDelegate的对象释放掉
            APP_DELEGATE.alarmClockTool = nil;
        }
        
    }

}

/**
 *  获取所有的闹钟事件
 *
 *  @return 返回所有闹钟事件的数组
 */
+ (NSArray*)GetAllAlarmClockEvent{
    //获取闹钟目录下的所有文件名
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[AlarmClockModel GetLocalPath] error:nil];
    NSMutableArray * clockArray = [NSMutableArray array];
    //这边文件名存储的时候存入的是时间值 所以需要将过期的闹钟事件移除掉
     NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
     dateFormatter.dateFormat = ClockDateFormatter;
    for (NSString * string in files) {
        //比较闹钟的时间跟当前时间的差值
        NSDate* inputDate = [dateFormatter dateFromString:string];
        int number =  [inputDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
        //闹钟任务还没有开始
        if (number > 0) {
            AlarmClockModel * model = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],string]];
            [clockArray addObject:model];
        }else{
        //已经开始过了的闹钟任务这里需要将其移除掉
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],string] error:nil];
        }
    }
    return clockArray;
}

/**
 *  获取本地的闹钟事件存储地址
 *
 *  @return
 */
+ (NSString *)GetLocalPath{

    NSFileManager * manger = [NSFileManager defaultManager];
    NSString *localPath = [NSString stringWithFormat:@"%@/Documents/AlarmClock", NSHomeDirectory()];
    //这边判断文件夹是否创建，如果文件夹不存在则创建
    if(![manger fileExistsAtPath:localPath]){
        [manger createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return localPath;
}




@end
