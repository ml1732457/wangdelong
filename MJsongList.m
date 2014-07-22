//
//  MJsongList1.m
//  倾音乐2.0
//
//  Created by qingyun on 14-7-19.
//  Copyright (c) 2014年 MJ. All rights reserved.
//

#import "MJsongList.h"
#import "MusicController.h"


static NSString *cellIdentifier = @"songcell";

@interface MJsongList () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,retain) NSMutableArray *songName;

@end

@implementation MJsongList

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _songName = [[NSMutableArray alloc]initWithCapacity:100];
        
        [_songName addObject: @"小苹果"];
        [_songName addObject: @"时间都去哪了"];
        [_songName addObject: @"爸爸去哪了"];
        [_songName addObject: @"光辉岁月"];
        [_songName addObject: @"你给我听好"];
        [_songName addObject: @"怒放的生命"];
        [_songName addObject: @"泡沫"];
        [_songName addObject: @"我只在乎你"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg4.png"]];
    
    [self.view addSubview: imageview];

    
    
    // 1. 创建TableView,用Plain风格来初始化，并设置tableView的属性
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(100, 0, 240, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    
    // 设置tableView的dataSource和delegate
    tableView.dataSource = self;
    tableView.delegate = self;
    
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg4.png"]];
    
    tableView.backgroundView =image;
    
    // 将tableView添加到self.view
    [self.view addSubview:tableView];
    
    tableView.separatorStyle= UITableViewCellEditingStyleNone;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.songName.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.songName[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithRed:0.83f green:0.89f blue:1 alpha:0.5];
    [cell setSelectedBackgroundView:bgView];
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//   取到歌名
    NSString *secletSongs = self.songName[indexPath.row];
    
    int idexOfRow = (int)indexPath.row;
//   取到位置
    NSNumber *currentMusicNumber = [NSNumber numberWithInt:idexOfRow];
    
//    通过通知传递消息
    _playCurrentMusic.message = secletSongs;
    _playCurrentMusic.indexOfTableView  = idexOfRow;
    
    //值发生改变的时候通知给监听的对象，并进行改变的动作。
    [[NSNotificationCenter defaultCenter] postNotificationName:@"indexRowChange" object:secletSongs];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"indexChange" object:currentMusicNumber];
    
    [self.navigationController popViewControllerAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}




@end
