//
//  AliyunUploadViewController.m
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunUploadViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AliyunPublishTopView.h"
#import "AliyunPublishService.h"
#import <sys/utsname.h>

@interface AliyunUploadViewController () <AliyunPublishTopViewDelegate, AliyunIUploadCallback>
@property (nonatomic, strong) AliyunPublishTopView *topView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) UILabel *uploadLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL finished;
@end

@implementation AliyunUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self setupPlayer];
    [AliyunPublishService service].uploadCallback = self;
    
//    NSString *keyId = @"STS.GGuYaL1yRHf15GqfgStAETgZ6";
//    NSString *keySecret = @"H1jLnUbXvdWMfve96iEvngfovW7bmLhahHCCt4QvUtke";
//    NSString *token = @"CAIS7gF1q6Ft5B2yfSjIpoTAEtv43KZz/6TaN2HAgmcGeM5pu6Lx1Dz2IHBLdHlgBOgXt/4ylGxV7vwblqZtTJMAWFTAasJ8q4ha6h/5kTA6UF72v9I+k5SANTW5LXyShb3zAYjQSNfaZY3aCTTtnTNyxr3XbCirW0ffX7SClZ9gaKZ4PGSmajYURq0hRG1YpdQdKGHaONu0LxfumRCwNkdzvRdmgm4NgsbWgO/ys0CD1gKl8IJP+dSteKrDRtJ3IZJyX+2y2OFLbafb2EZSkUMaq/cm3PEcqG6d44HBXgELug/lLe3Y/tBqKxV+YqUqrhQrGoABZuZTti0i6MH7nSikhO20a4hkPd/eNaNN/0zzF7/LP3dYhl8qYWZEdcivE/uHlBGvFRdgr1/PQ32ygrFs1iZ5yOJ2+an+ZMkZhtpUACpHcox1lErZjITmAsac67dsh8fto0qxPgKpgmJ6rCc9S1+8f8ft+vaSXBstntddtAhxeZg=";
    
    [self requestSTSWithHandler:^(NSString *keyId, NSString *keySecret, NSString *token, NSString *expireTime, NSError *error) {
        if (error) {
            return ;
        }
        AliyunUploadSVideoInfo *info = [AliyunUploadSVideoInfo new];
        info.title = @"test video";
        //[[AliyunPublishService service] uploadWithImagePath:<#(NSString *)#> svideoInfo:<#(AliyunUploadSVideoInfo *)#> accessKeyId:<#(NSString *)#> accessKeySecret:<#(NSString *)#> accessToken:<#(NSString *)#>]
        [[AliyunPublishService service] uploadWithImagePath:_coverImagePath svideoInfo:info accessKeyId:keyId accessKeySecret:keySecret accessToken:token];
    }];
}

- (void)setupSubviews {
    self.topView = [[AliyunPublishTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, StatusBarHeight+44)];
    self.topView.nameLabel.text = @"我的视频";
    self.topView.delegate = self;
    self.topView.finishButton.hidden = YES;
    [self.topView.cancelButton setImage:[AliyunImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.topView.cancelButton setTitle:nil forState:UIControlStateNormal];
    [self.view addSubview:self.topView];
    self.view.backgroundColor = [AliyunIConfig config].backgroundColor;
    
    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, StatusBarHeight+44, ScreenWidth, ScreenWidth * _videoSize.height/_videoSize.width)];
    [self.view addSubview:self.playView];
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, StatusBarHeight+44, ScreenWidth, 4)];
    self.progressView.backgroundColor = rgba(0, 0, 0, 0.6);
    self.progressView.progressTintColor = [AliyunIConfig config].timelineTintColor;
    [self.view addSubview:self.progressView];
    
    self.uploadLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-140)/2, StatusBarHeight+44+24, 140, 32)];
    self.uploadLabel.backgroundColor = rgba(35, 42, 66, 0.5);
    self.uploadLabel.layer.cornerRadius = 2;
    self.uploadLabel.layer.masksToBounds = YES;
    self.uploadLabel.textColor = [UIColor whiteColor];
    [self.uploadLabel setFont:[UIFont systemFontOfSize:14]];
    self.uploadLabel.textAlignment = NSTextAlignmentCenter;
    self.uploadLabel.hidden = YES;
    [self.view addSubview:self.uploadLabel];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, StatusBarHeight+44+(ScreenWidth * _videoSize.height/_videoSize.width), ScreenWidth-40, 40)];
    self.titleLabel.text = _desc;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:self.titleLabel];
    
}

- (void)setupPlayer {
    NSURL *videoUrl = [NSURL fileURLWithPath:_videoPath];
    _playerItem = [[AVPlayerItem alloc] initWithURL:videoUrl];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    _playerLayer.frame = self.playView.bounds;
    [self.playView.layer addSublayer:_playerLayer];
    [self addObserver:self forKeyPath:@"_playerItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _playerLayer.frame = self.playView.bounds;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"_playerItem.status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)appWillEnterForeground:(id)sender {
    [_player play];
}

- (void)appDidEnterBackground:(id)sender {
    [_player pause];
}

#pragma mark - observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"_playerItem.status"]) {
        AVPlayerItemStatus status = _playerItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            [_player play];
        }
    }
}

#pragma mark - top view delegate

-(void)cancelButtonClicked {
    if (!_finished) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"正在上传视频，确定要放弃上传吗？" message:nil delegate:self cancelButtonTitle:@"取消上传" otherButtonTitles:@"继续上传", nil];
        alert.tag = 101;
        [alert show];
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)finishButtonClicked {
    
}

#pragma mark -alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView.tag == 101) {
            [[AliyunPublishService service] cancelUpload];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - upload callback

-(void)uploadProgressWithUploadedSize:(long long)uploadedSize
                            totalSize:(long long)totalSize {
    if (totalSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat progress = uploadedSize/(double)totalSize;
            [_progressView setProgress:progress];
            [self updateUploadLabelWithProgress:progress];
        });
    }
}

-(void)uploadTokenExpired {
    [self requestSTSWithHandler:^(NSString *keyId, NSString *keySecret, NSString *token, NSString *expireTime, NSError *error) {
        if (error) {
            [[AliyunPublishService service] cancelUpload];
        }else {
            [[AliyunPublishService service] refreshWithAccessKeyId:keyId accessKeySecret:keySecret accessToken:token expireTime:expireTime];
        }
    }];
}

-(void)uploadFailedWithCode:(NSString *)code message:(NSString *)message {
    NSLog(@"upload failed code:%@, message:%@", code, message);
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.hidden = YES;
        _uploadLabel.hidden = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"上传失败\ncode:%@\nmessage:%@",code,message] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    });
}

-(void)uploadSuccessWithVid:(NSString *)vid imageUrl:(NSString *)imageUrl {
    NSLog(@"upload success vid:%@, imageurl:%@", vid, imageUrl);
    _finished = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _progressView.hidden = YES;
        _uploadLabel.hidden = YES;
    });
}

-(void)uploadRetry {
    
}

-(void)uploadRetryResume {
    
}

#pragma mark - sts request

- (void)requestSTSWithHandler:(void (^)(NSString *keyId, NSString *keySecret, NSString *token,NSString *expireTime,  NSError * error))handler {
    // 测试用请求地址
    NSString *params = [NSString stringWithFormat:@"BusinessType=vodai&TerminalType=iphone&DeviceModel=%@&UUID=%@&AppVersion=1.0.0", [self getDeviceId], [self getDeviceModel]];
    NSString *testRequestUrl = [NSString stringWithFormat:@"http://106.15.81.230/voddemo/CreateSecurityToken?%@",params];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:testRequestUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            handler(nil,nil,nil,nil, error);
            return ;
        }
        if (data == nil) {
            NSError *emptyError = [[NSError alloc] initWithDomain:@"Empty Data" code:-10000 userInfo:nil];
            handler(nil,nil,nil,nil, emptyError);
            return ;
        }
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            handler(nil,nil,nil,nil, error);
            return;
        }
        NSDictionary *dict = [jsonObj objectForKey:@"SecurityTokenInfo"];
        NSString *keyId = [dict valueForKey:@"AccessKeyId"];
        NSString *keySecret = [dict valueForKey:@"AccessKeySecret"];
        NSString *token = [dict valueForKey:@"SecurityToken"];
        NSString *expireTime = [dict valueForKey:@"Expiration"];
        if (!keyId || !keySecret || !token || !expireTime) {
            NSError *emptyError = [[NSError alloc] initWithDomain:@"Empty Data" code:-10000 userInfo:nil];
            handler(nil,nil,nil,nil, emptyError);
            return ;
        }
        handler(keyId, keySecret, token, expireTime, error);
    }];
    [task resume];
}

#pragma mark - util

-(void)updateUploadLabelWithProgress:(CGFloat)progress {
    if (progress < 0) {
        return;
    }
    if (progress < 1) {
        self.uploadLabel.text = [NSString stringWithFormat:@"正在上传 %d%%", (int)(progress*100)];
    }else {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"  上传成功"];
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [AliyunImage imageNamed:@"icon_upload_success"];
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
        self.uploadLabel.attributedText = attributedString;
    }
    _uploadLabel.hidden = NO;
}

- (NSString *)getDeviceId {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString*)getDeviceModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}


@end
