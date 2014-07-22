//
//  MusicController.h
//  MyMusicPlayer
//
//  Created by qingyun on 14-7-15.
//  Copyright (c) 2014年 com.hnqingyun.wangdelong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface MusicController : UIViewController
{
    NSUInteger lrcLineNumber;
}



@property (nonatomic,retain) NSString *message;
@property (nonatomic,assign) int indexOfTableView;


@property (nonatomic,retain) NSURL *soundFlieUrl;

@end
