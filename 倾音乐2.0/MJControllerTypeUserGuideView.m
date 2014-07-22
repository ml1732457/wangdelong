//
//  MJControllerTypeUserGuideView.m
//  倾音乐2.0
//
//  Created by qingyun on 14-7-19.
//  Copyright (c) 2014年 MJ. All rights reserved.
//

#import "MJControllerTypeUserGuideView.h"


@interface MJControllerTypeUserGuideView ()

@end

@implementation MJControllerTypeUserGuideView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if 0
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
    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4]];
    
    [intro setDelegate:self];
    
    [intro showInView:self.view animateDuration:0.3];
}

- (void)introDidFinish {
    
    
    MusicController *musicViewController = [[MusicController alloc]init];
    
    [self.navigationController pushViewController:musicViewController animated:YES];
    
}
#endif

@end
