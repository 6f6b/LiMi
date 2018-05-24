//
//  AliyunVideoPreViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunVideoPreViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AliyunPhotoLibraryManager.h"
static NSString *const PlayerItemStatus = @"_playerItem.status";
@interface AliyunVideoPreViewController ()
@property (nonatomic, strong) UIButton *buttonReRecord;
@property (nonatomic, strong) UIButton *buttonFinish;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation AliyunVideoPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSURL *videoUrl = [NSURL fileURLWithPath:_videoPath];
    _playerItem = [[AVPlayerItem alloc] initWithURL:videoUrl];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    _playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:_playerLayer];
    [self addObserver:self forKeyPath:PlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    
    [self setupSubViews];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)appWillEnterForeground:(id)sender
{
    [_player play];
}

- (void)appDidEnterBackground:(id)sender
{
    [_player pause];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupSubViews {
    
    UIView *headerBackgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, SafeTop, ScreenWidth, 54)];
    [self.view addSubview:headerBackgroudView];
    headerBackgroudView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2];
    
    _buttonReRecord = [self setupButtonWithFrame:CGRectMake(0, SafeTop+10, 34, 34)];
    _buttonFinish = [self setupButtonWithFrame:CGRectMake(ScreenWidth - 34, SafeTop+10, 34, 34)];
    
    [_buttonReRecord setImage:[AliyunImage imageNamed:@"back"] forState:0];
    [_buttonFinish setImage:[AliyunImage imageNamed:@"next"] forState:0];
    
    [_buttonReRecord addTarget:self action:@selector(buttonBackReRecordClick) forControlEvents:UIControlEventTouchUpInside];
    [_buttonFinish addTarget:self action:@selector(buttonFinishClick) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)setupButtonWithFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    [self.view addSubview:button];
    return button;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _playerLayer.frame = self.view.bounds;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:PlayerItemStatus]) {
        AVPlayerItemStatus status = _playerItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            [_player play];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:PlayerItemStatus];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buttonBackReRecordClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonFinishClick {
    NSURL *videoUrl = [NSURL fileURLWithPath:_videoPath];
    [[AliyunPhotoLibraryManager sharedManager] saveVideoAtUrl:videoUrl toAlbumName:nil completion:^(NSError *error) {
        if (!error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

@end
