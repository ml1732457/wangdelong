//
//  MJviewControlleManager.h
//  倾音乐2.0
//
//  Created by qingyun on 14-7-19.
//  Copyright (c) 2014年 MJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MjViewControllerType) {
    
    MJControllerTypeUserGuideView,
    MJMusicController
};

@interface MJviewControlleManager : NSObject

//创建类方法，控制视图切换
+ (void) persentMJController:(MjViewControllerType)controller;

@end
