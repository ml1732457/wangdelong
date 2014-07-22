//
//  MusicController.m
//  MyMusicPlayer
//
//  Created by qingyun on 14-7-15.
//  Copyright (c) 2014年 com.hnqingyun.wangdelong. All rights reserved.
//

#import "MusicController.h"
#import "Music.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define showLyrTable 10000

//设置播放模式的枚举
typedef enum {
    
    DefaultMode,
    randomPlay,
    allLoopMode
    
}loopMode;

@interface MusicController () <UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>


//背景视图的界面
@property (weak, nonatomic) IBOutlet UIImageView *changeBackgroundImage;

//底部控制按钮，放在了一个view上
@property (weak, nonatomic) IBOutlet UIView *controllerView;

@property (weak, nonatomic) IBOutlet UIButton *btnPreMusic;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnNextMusic;


@property (weak, nonatomic) IBOutlet UIButton *btnCirculate;


//进城条还有配对的两个label
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property (weak, nonatomic) IBOutlet UILabel *progressMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressMaxLabel;


@property (retain, nonatomic) UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *voiceMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *voiceMaxLabel;


//歌词显示时用的tabelview
@property (weak, nonatomic) IBOutlet UITableView *showLyr;


//显示歌名
@property (weak, nonatomic) IBOutlet UILabel *songName;


@property (nonatomic, retain) NSTimer *playerTimer;



//歌曲数组
@property (retain,nonatomic)NSMutableArray *musicArray;
//歌曲
@property (assign,nonatomic)NSUInteger numberOfMusicArray;

@property (retain,nonatomic)Music *currentMusic;


//这里学习的是AVAudioPlayer
@property(nonatomic,retain) AVAudioPlayer *audioPlayer;
//创建系统的音乐条
@property (nonatomic,retain)MPVolumeView *systemVolumeView;

//全局变量，用于判别播放模式
@property (nonatomic,assign) NSUInteger loopMode;


//播放时间的数组
@property (nonatomic,retain)NSMutableArray *timeArray;
//正在播放的行数
//@property (nonatomic,assign)NSUInteger lrcLineNumber;


@property (nonatomic,retain)NSMutableDictionary *LRCDictionary;

@property (nonatomic,assign)NSInteger musicNum;

@property (nonatomic,assign) int indexRowNew;

@property (nonatomic,retain)NSError *error;

@end

@implementation MusicController

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
    
    _loopMode = 0;
    
//  点击发亮
    self.btnPlay.showsTouchWhenHighlighted = YES;
    self.btnNextMusic.showsTouchWhenHighlighted=YES;
    self.btnPreMusic.showsTouchWhenHighlighted=YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    _showLyr.backgroundColor = [UIColor clearColor];
    _controllerView.backgroundColor= [UIColor clearColor];
        
    //实现后台播放
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];


    //注册一个通知，说明所在的视图控制器在其他控制器改变值的时候通知我
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotify:)
                                                 name:@"indexRowChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyIndex:)
                                                 name:@"indexChange" object:nil];

  /*
//    self.view.backgroundColor = [UIColor lightGrayColor];
//    self.navigationController.navigationBarHidden = YES;
//    self.changeBackgroundImage.animationImages = @[[UIImage imageNamed:@"scene1.jpg"],
//                                       [UIImage imageNamed:@"scene2.jpg"],
//                                       [UIImage imageNamed:@"scene3.jpg"],
//                                       [UIImage imageNamed:@"scene4.jpg"],
//                                       [UIImage imageNamed:@"scene5.jpg"],
//                                       ];
//    
//    self.changeBackgroundImage.animationDuration = 20.0;
//    [self.changeBackgroundImage stopAnimating];
//    [self.view addSubview:self.changeBackgroundImage];
//    [self.changeBackgroundImage addSubview:self.songName];
//    [self.changeBackgroundImage addSubview:self.showLyr];
//    [self.changeBackgroundImage addSubview:self.progressSlider];
//    [self.changeBackgroundImage addSubview:self.progressMinLabel];
//    [self.changeBackgroundImage addSubview:self.progressMaxLabel];
//    [self.changeBackgroundImage addSubview:self.voiceMaxLabel];
//    [self.changeBackgroundImage addSubview:self.voiceMinLabel];
//    [self.changeBackgroundImage addSubview:self.controllerView];
    */
//1.
    //创建url对象，对应要播放的歌曲地址
    //初始化要加载的曲目
    //利用歌曲的数组进行加载，默认第一首歌
//   初始化歌曲
    [self initMusic];
    self.numberOfMusicArray = 0;
    _songName.text = [_musicArray[self.numberOfMusicArray] name];
    _songName.textAlignment = NSTextAlignmentCenter;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[_musicArray[self.numberOfMusicArray] name] ofType:@"mp3"]] error:nil];
    
     _audioPlayer.delegate = self;
    
    _currentMusic = _musicArray[_numberOfMusicArray];
        //  事先将音频数据从文件里加载到内存， 这块内存又叫做音频播知的缓冲区
    [_audioPlayer prepareToPlay];
    
    [self.btnCirculate setBackgroundImage:[UIImage imageNamed:@"mode_orderplay@2x"]
                                 forState:UIControlStateNormal];
    
    //   设置显示歌词的tableview
    _showLyr.separatorStyle = UITableViewCellSeparatorStyleNone;
    _showLyr.delegate = self;
    _showLyr.dataSource =self;
    
    //    初始化
    lrcLineNumber = 0;
    _timeArray = [[NSMutableArray alloc] initWithCapacity:10];
    _LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    //    初始化歌词
    [self initLRC];

    
//   关于其他UI的一些设计
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"]
                             forState:UIControlStateNormal];
    //  设置播放的进程条
    self.progressSlider.minimumValue=0;
    //  进度的最大值就是歌曲的总时长
    self.progressSlider.maximumValue=self.audioPlayer.duration;
    
   
    
    //  设置音量的进程条--------value的范围是0到1之间
    [self customSlider];
     _slider.value=25;
    _voiceMinLabel.text = [NSString  stringWithFormat:@"%d", 25];
    
    self.audioPlayer.volume = (float)(_slider.value /50);
    
    
    //  添加事件
    [_progressSlider addTarget:self action:@selector(changgeProgressSlider:) forControlEvents:UIControlEventValueChanged];
    
    [_btnPreMusic addTarget:self action:@selector(btnleft:) forControlEvents:UIControlEventTouchDown];
    
    [_btnNextMusic addTarget:self action:@selector(btnright:) forControlEvents:UIControlEventTouchDown];
    
    //添加一个定时器，每过0.1f触发事件，
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showTime:) userInfo:nil repeats:YES];
}

#pragma  歌曲载入
//载入歌曲数组
-(void)initMusic
{
    Music *music = [[Music alloc]initWithName:@"小苹果" andType:@"mp3"];
    Music *music2 = [[Music alloc]initWithName:@"时间都去哪了" andType:@"mp3"];
    Music *music3 = [[Music alloc]initWithName:@"爸爸去哪了" andType:@"mp3"];
    Music *music4 = [[Music alloc]initWithName:@"光辉岁月" andType:@"mp3"];
    Music *music5= [[Music alloc]initWithName:@"你给我听好" andType:@"mp3"];
    Music *music6 = [[Music alloc]initWithName:@"怒放的生命" andType:@"mp3"];
    Music *music7 = [[Music alloc]initWithName:@"泡沫" andType:@"mp3"];
    Music *music8 = [[Music alloc]initWithName:@"我只在乎你" andType:@"mp3"];
    
     _musicArray = [[NSMutableArray alloc]initWithCapacity:2000];
    
    [_musicArray addObject:music];
    [_musicArray addObject:music2];
    [_musicArray addObject:music3];
    [_musicArray addObject:music4];
    [_musicArray addObject:music5];
    [_musicArray addObject:music6];
    [_musicArray addObject:music7];
    [_musicArray addObject:music8];
}

#pragma  显示播放时间
#if 1
- (void)showTime: (NSTimer *)time{
    
    //动态更新进度条时间
    self.progressSlider.value =_audioPlayer.currentTime ;
    //调用歌词函数
    [self displaySondWord:_audioPlayer.currentTime];
    
    _progressMinLabel.text = [self formatSongDuration:self.audioPlayer.currentTime];
    _progressMaxLabel.text = [self formatSongDuration:_audioPlayer.duration];
   
    /*
    if ((int)_audioPlayer.currentTime % 60 < 10) {
        _progressMinLabel.text = [NSString stringWithFormat:@"%d:0%d",(int)_audioPlayer.currentTime / 60, (int)_audioPlayer.currentTime % 60];
    } else {
        _progressMinLabel.text = [NSString stringWithFormat:@"%d:%d",(int)_audioPlayer.currentTime / 60, (int)_audioPlayer.currentTime % 60];
    }
    
    if ((int)_audioPlayer.duration % 60 < 10) {
        _progressMaxLabel.text = [NSString stringWithFormat:@"%d:0%d",(int)_audioPlayer.duration / 60, (int)_audioPlayer.duration % 60];
    } else {
        _progressMaxLabel.text = [NSString stringWithFormat:@"%d:%d",(int)_audioPlayer.duration / 60, (int)_audioPlayer.duration % 60];
        
     */
}

#pragma mark - 自定义计算歌曲进度时间的方法
- (NSString*)formatSongDuration:(NSTimeInterval)total {
    
    NSString *strMint = [NSString stringWithFormat:@"%02d",((int)total / 60)];
    NSString *strSecond = [NSString stringWithFormat:@"%02d",((int)total % 60)];
   return [NSString stringWithFormat:@"%@:%@",strMint,strSecond];

}
#endif


//对播放按键的处理
- (IBAction)playMusic:(UIButton *)sender
{
    //  对播放状态的一个处理，如果当前是正在播放状态时
    if ([self.audioPlayer isPlaying]) {
        //       点击播放按钮，变成暂停
     [_btnPlay setBackgroundImage:[UIImage imageNamed:@"channel_friend_play"]
                            forState:UIControlStateNormal];
    //        pause暂停
         [_audioPlayer pause];
    }else
    {
    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"channel_friend_pause"]
                            forState:UIControlStateNormal];

        //       再点击，重新接着开始播放
        [_audioPlayer play];
    }
    
    _audioPlayer.volume = _slider.value/50;//重置音量,(每次播放的默认音量好像是1.0)
    
}

#pragma 进程slider的事件
//传的是时间
-(void)changgeProgressSlider: (UISlider *)sender
{
//    传值，让slider的当前的value值作为音乐播放的currentTime
    
    self.audioPlayer.currentTime = sender.value;
    
    
}

#pragma 声音slider的事件
//根据值改变
-(void)changgeVoiceSlider:(UISlider *)sender
{
    self.audioPlayer.volume =(float) sender.value/50  ;
    
    _voiceMinLabel.text = [NSString stringWithFormat:@"%d",(int)self.slider.value];
    
}

#pragma mark - 创建系统音量条
- (void)createdMpVolumeView {
    _systemVolumeView = [[MPVolumeView alloc]
                         initWithFrame:_controllerView.bounds];
    
    [_systemVolumeView setVolumeThumbImage:[UIImage imageNamed:@"playing_volumn_slide"]
                                  forState:UIControlStateNormal];
    [_systemVolumeView sizeToFit];
    [_controllerView addSubview:_systemVolumeView];
    
}

#pragma mark 上一首
- (void)btnleft:(UIButton *)sender
{
    [_audioPlayer stop];
     NSInteger number = arc4random()%_musicArray.count;
    switch (_loopMode%3) {
        case 0:
            if (_numberOfMusicArray == 0) {
                
                _numberOfMusicArray = _musicArray.count - 1;
            }else
            {
                _numberOfMusicArray --;}
            
            [self playCurrentMusic];
            
            break;
        case 1:
            if (_numberOfMusicArray !=number) {
                _numberOfMusicArray = number;
                
                [self playCurrentMusic];
            }
            
        case 2:
            
            [self playCurrentMusic];
            
        default:
            break;
    }
    
}

#pragma mark 下一首
//播放下一首歌曲
- (void )btnright:(UIButton *)sender
{
    [_audioPlayer stop];
    NSInteger number = arc4random()%_musicArray.count;
    switch (_loopMode%3) {
        case 0:
            if (_numberOfMusicArray == _musicArray.count - 1) {
                
               _numberOfMusicArray = 0 ;
                
            }else
            {
                _numberOfMusicArray ++;}
            
            [self playCurrentMusic];
            
            break;
            
        case 1:
            if (_numberOfMusicArray !=number) {
                _numberOfMusicArray = number;
                
                [self playCurrentMusic];
            }
            
        case 2:
            
            [self playCurrentMusic];
            
        default:
            break;
    }

}


#pragma mark 摇一摇 换歌
- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion == UIEventSubtypeMotionShake) {
        if (_numberOfMusicArray == _musicArray.count - 1) {
            _numberOfMusicArray = 0;
        }
        _numberOfMusicArray ++;
        
        [self playCurrentMusic];
    }
}

#pragma mark -playCurrentMusic
- (void)playCurrentMusic {
    
//    更新歌名
    _songName.text = [_musicArray[self.numberOfMusicArray] name];
    _songName.textAlignment = NSTextAlignmentCenter;
    
    //更新曲目
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[_musicArray[self.numberOfMusicArray] name] ofType:@"mp3"]] error:nil];
    
    //    初始化歌词
    _timeArray = [[NSMutableArray alloc] initWithCapacity:10];
    _LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self initLRC];
    [_showLyr reloadData];

    //更新音量
    _audioPlayer.volume = (float)_slider.value/50;
    
    self.progressSlider.maximumValue=self.audioPlayer.duration;

    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"channel_friend_pause"]
                        forState:UIControlStateNormal];

    _currentMusic = _musicArray[_numberOfMusicArray];
    
    
    [_audioPlayer play];
}

#pragma mark -customSlider
//自定义一个竖着的slider
-(void)customSlider
{
_slider = [[UISlider alloc] initWithFrame:CGRectMake(-90, 230, 214, 10)];
//设置旋转90度
_slider.transform = CGAffineTransformMakeRotation(1.57079633);
//设置最小数
_slider.minimumValue=0;
//设置最大数
_slider.maximumValue=50;
//设置背景颜色
_slider.backgroundColor = [UIColor clearColor];
//设置按钮界面
[_slider setThumbImage:[UIImage imageNamed:@"slider_thumb2"]
                              forState:UIControlStateNormal];
[_slider addTarget:self action:@selector(changgeVoiceSlider:) forControlEvents:UIControlEventValueChanged];
//添加到VIEW
[self.view addSubview:_slider];

}

#pragma mark - 播放模式的改变
- (IBAction)musicControllerButton:(id)sender {
    
     ++_loopMode;
    switch (_loopMode%3) {
           
        case 0:
            [self doDefaultMode];
            self.audioPlayer.delegate = self;
            [self.btnCirculate setBackgroundImage:[UIImage imageNamed:@"mode_orderplay@2x"]forState:UIControlStateNormal];
            break;
        case 1:
           
            [self doRandomPlay];
            self.audioPlayer.delegate = self;
            [self.btnCirculate setBackgroundImage:[UIImage imageNamed:@"mode_randplay@2x"]forState:UIControlStateNormal];
            break;
        case 2:
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.delegate = self;
            [self.btnCirculate setBackgroundImage:[UIImage imageNamed:@"mode_repeatlist@2x"]forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}
//顺序播放
- (void)doDefaultMode
{
    
    if ( _numberOfMusicArray == _musicArray.count - 1) {
        
        _numberOfMusicArray = 0;
            }
    else{
        _numberOfMusicArray++;
                
    }
    
}

//随机播放
- (void)doRandomPlay
{
   
    //if (self.audioPlayer.currentTime >= self.audioPlayer.duration-1.05) {
    NSInteger number = arc4random()%_musicArray.count;
    
    _numberOfMusicArray = number;
    
}

#if 1
#pragma  mark - 播放完成后的代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    
    switch (_loopMode%3) {
            
        case 0: {
            
            if (_numberOfMusicArray != (_musicArray.count -1)) {
                _numberOfMusicArray++;
                [self playCurrentMusic];
                
            }else {
                _numberOfMusicArray = 0;
                [self playCurrentMusic];
                [_audioPlayer play];
            }
            break;
            
        case 1: {
            
            NSInteger number = arc4random()%_musicArray.count;
            if (_numberOfMusicArray !=number) {
                
                _numberOfMusicArray = number;
                [self playCurrentMusic];
                [_audioPlayer play];

            }
                   }
            break;
            
        case 2: {
            
            if (_numberOfMusicArray < (_musicArray.count -1)||_numberOfMusicArray == (_musicArray.count -1)){
                _audioPlayer.numberOfLoops = -1;
                [self playCurrentMusic];
                [_audioPlayer play];
            }
        }
            break;
        }
        default:
            break;
    }
}
#endif
#pragma mark - 通知接收动作：接收字符串
- (void)onNotify:(NSNotification*)notification {
    
    //定义一个字符串来接收传进来的对象------歌曲名字
    NSString *str = [notification object];
    _songName.textAlignment = NSTextAlignmentCenter;
    _songName.text = str;
    
    _soundFlieUrl = [[NSBundle mainBundle] URLForResource:str
                                            withExtension:@"mp3"];
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:
     _soundFlieUrl error:nil];
    
//  _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:str  ofType:@"mp3"]] error:nil];
    [self playCurrentMusic];
//    [_audioPlayer play];
    
}

#pragma mark - 通知接收动作：接收索引值
- (void)onNotifyIndex:(NSNotification*)notification {
    
    NSNumber *indexRowOld = [notification object];
    
    _numberOfMusicArray = [indexRowOld intValue];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[_musicArray[self.numberOfMusicArray] name] ofType:@"mp3"]] error:nil];
    
    [self.btnPlay setBackgroundImage:[UIImage imageNamed:@"channel_friend_pause"]
                            forState:UIControlStateNormal];
    _currentMusic = _musicArray[_numberOfMusicArray];
    
    //更新音量
    _audioPlayer.volume = _slider.value;
    
    [self playCurrentMusic];
//    [_audioPlayer play];
    
}




#if 1
#pragma mark -
#pragma datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_error != nil)
    {
        return 1;
        }
    
        return _timeArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"LRCCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (_error != nil) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//该表格选中后没有颜色
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text= @"对不起，暂时没有歌词";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }else{
      if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//该表格选中后没有颜色
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == lrcLineNumber) {
        cell.textLabel.text = _LRCDictionary[_timeArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    } else {
        
        cell.textLabel.text = _LRCDictionary[_timeArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    //        cell.textLabel.textColor = [UIColor blackColor];
    
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    //        [cell.contentView addSubview:lable];//往列表视图里加 label视图，然后自行布局

    }
    return cell;

}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}
#endif


#if 1
#pragma mark 得到歌词
- (void)initLRC {
    
    NSString *LRCPath = [[NSBundle mainBundle] pathForResource:[_musicArray[_numberOfMusicArray] name] ofType:@"lrc"];
    
    NSError *error = nil;
        NSString *contentStr = [NSString stringWithContentsOfFile:LRCPath encoding:NSUTF8StringEncoding error:&error];
    _error = error;
    
    NSLog(@"%@",error);
    
        if (error == nil) {
            
        NSArray *array = [contentStr componentsSeparatedByString:@"\n"];
        
        for (int i = 0; i < [array count]; i++) {
            
            NSString *linStr = [array objectAtIndex:i];
            NSArray *lineArray = [linStr componentsSeparatedByString:@"]"];
            
            if ([lineArray[0] length] > 8) {
                
                NSString *str1 = [linStr substringWithRange:NSMakeRange(3, 1)];
                NSString *str2 = [linStr substringWithRange:NSMakeRange(6, 1)];
                
                if ([str1 isEqualToString:@":"] && [str2 isEqualToString:@"."]) {
                    
                    NSString *lrcStr = [lineArray objectAtIndex:1];
                    NSString *timeStr = [[lineArray objectAtIndex:0] substringWithRange:NSMakeRange(1, 5)];//分割区间求歌词时间
                    //把时间 和 歌词 加入词典
                    [_LRCDictionary setObject:lrcStr forKey:timeStr];
                    
                    [_timeArray addObject:timeStr];//timeArray的count就是行数
                }
            }
        }

        }else{
            
            _LRCDictionary = nil;
            _timeArray = nil;
            
        }
}


#pragma mark 动态显示歌词
- (void)displaySondWord:(NSUInteger)time {
    
//    NSLog(@"time = %u",time);
    for (int i = 0; i < [_timeArray count]; i++) {
        
        NSArray *array = [_timeArray[i] componentsSeparatedByString:@":"];//把时间转换成秒
        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
        if (i == [_timeArray count]-1) {
            //求最后一句歌词的时间点
            NSArray *array1 = [_timeArray[_timeArray.count-1] componentsSeparatedByString:@":"];
            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
            
            if (time > currentTime1) {
                
                [self updateLrcTableView:i];
                break;
            }
        } else {
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [_timeArray[0] componentsSeparatedByString:@":"];
            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
            if (time < currentTime2) {
               
                [self updateLrcTableView:0];
                NSLog(@"马上到第一句");
                break;
            }
            //求出下一步的歌词时间点，然后计算区间
            NSArray *array3 = [_timeArray[i+1] componentsSeparatedByString:@":"];
            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
            if (time >= currentTime && time <= currentTime3) {
               
                
                [self updateLrcTableView:i];
                break;
                
            }
        }
    }
/*
#if 0
    //    NSLog(@"time = %u",time);
    for (int i = 0; i < [_timeArray count]; i++) {
        
        NSArray *array = [_timeArray[i] componentsSeparatedByString:@":"];//把时间转换成秒
        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
        
        if (i == [_timeArray count]-1) {
            //求最后一句歌词的时间点
            NSArray *array1 = [_timeArray[_timeArray.count-1] componentsSeparatedByString:@":"];
            
            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
            
            if (time > currentTime1) {
                
                [self updateLrcTableView:i];
                
                break;
            }
            
        } else {
            
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [_timeArray[0] componentsSeparatedByString:@":"];
            
            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
            
            if (time < currentTime2) {
                
                [self updateLrcTableView:0];
                //                NSLog(@"马上到第一句");
                break;
            }
            //求出下一步的歌词时间点，然后计算区间progressSlider.value = audioPlayer.currentTime / audioPlayer.duration;
            
            NSArray *array3 = [_timeArray[i+1] componentsSeparatedByString:@":"];
            
            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
            if (time >= currentTime && time <= currentTime3) {
                
                [self updateLrcTableView:i];
                
                break;
            }
            
        }
    }
#endif
 */
}

#pragma mark 动态更新歌词表歌词
- (void)updateLrcTableView:(NSUInteger)lineNumber {
    
//    NSLog(@"lrc = %@", [_LRCDictionary objectForKey:[_timeArray objectAtIndex:lineNumber]]);
    //重新载入 歌词列表
    lrcLineNumber = lineNumber;
    
    [_showLyr reloadData];
    
    //使被选中的行移到中间
    NSIndexPath *indexPa = [NSIndexPath indexPathForRow:lineNumber inSection:0];
    
    
    [_showLyr scrollToRowAtIndexPath:indexPa atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [_showLyr selectRowAtIndexPath:indexPa
                          animated:YES
                    scrollPosition:UITableViewScrollPositionMiddle];

   }

//UITableViewScrollPositionMiddle
#endif

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
