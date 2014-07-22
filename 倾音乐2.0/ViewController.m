//
//  ViewController.m
//  倾音乐2.0
//
//  Created by qingyun on 14-7-18.
//  Copyright (c) 2014年 MJ. All rights reserved.
//

#import "ViewController.h"
#import "MusicController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

static NSString * const sampleDesc1 = @"想听歌怎么办？";
static NSString * const sampleDesc2 = @"好烦";
static NSString * const sampleDesc3 = @"专门定制";
static NSString * const sampleDesc4 = @"倾听";


@interface ViewController ()

@property (retain,nonatomic)AVPlayer *musicPlayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationController.navigationBarHidden = YES;

    
    if ([enterState boolForKey:@"firstEnter"]) {
        
        [self showIntroWithCrossDissolve];
        
        
    }else {
        
        
        NSURL *musicURL = [[NSBundle mainBundle] URLForResource:@"酷狗" withExtension:@"mp3"];
        self.musicPlayer = [[AVPlayer alloc] initWithURL:musicURL];
        [self.musicPlayer play];
        
        UIImageView *viewImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg5.jpg"]];
        
       
        viewImage.frame = self.view.bounds;
        
        viewImage.tag = 521;
        
        [self.view addSubview:viewImage];
        
        self.view.userInteractionEnabled = NO;
        
        //添加一个定时器，每过0.1f触发事件，
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(doSomething) userInfo:nil repeats:NO];
    }

}


-(void)doSomething

{
    UIImageView *image =  (UIImageView *)[self.view viewWithTag:521];
    
    [image removeFromSuperview];
    
    NSLog(@"hello");
    
    MusicController *musicViewController = [[MusicController alloc]init];
    [self.navigationController pushViewController:musicViewController animated:YES];
}

- (void)showIntroWithCrossDissolve {
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"";
    page1.desc = sampleDesc1;
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleImage = [UIImage imageNamed:@"title1"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"";
    page2.desc = sampleDesc2;
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    page2.titleImage = [UIImage imageNamed:@"title2"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"";
    page3.desc = sampleDesc3;
    page3.bgImage = [UIImage imageNamed:@"bg3"];
    page3.titleImage = [UIImage imageNamed:@"title3"];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"";
    page4.desc = sampleDesc4;
    page4.bgImage = [UIImage imageNamed:@"bg4"];
    page4.titleImage = [UIImage imageNamed:@"title4"];
 
    /*
//    EAIntroPage *page5 = [EAIntroPage page];
//    page4.title = @"";
//    page4.desc = sampleDesc4;
//    page4.bgImage = [UIImage imageNamed:@"bg5.jpeg"];
//    page4.titleImage = [UIImage imageNamed:@""];
  */
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4]];
    
    [intro setDelegate:self];
    
    [intro showInView:self.view animateDuration:0.3];
}

- (void)introDidFinish {
    

    MusicController *musicViewController = [[MusicController alloc]init];
    
    [self.navigationController pushViewController:musicViewController animated:YES];
    
    }


@end
