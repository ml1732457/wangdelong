//
//  AppDelegate.h
//  倾音乐2.0
//
//  Created by qingyun on 14-7-18.
//  Copyright (c) 2014年 MJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  IIViewDeckController;
@class  MJsongList;
@class  MJmainList;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong,nonatomic)IIViewDeckController *desk;
@property (strong,nonatomic)MJmainList *mainList;
@property (strong,nonatomic)MJsongList *songList;

@end
