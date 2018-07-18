//
//  AliyunCoverPickViewController.m
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCoverPickViewController.h"
#import "AliyunPublishTopView.h"
#import "AliyunCoverPickView.h"

@interface AliyunCoverPickViewController () <AliyunPublishTopViewDelegate, AliyunCoverPickViewDelegate>
@property (nonatomic, strong) AliyunPublishTopView *topView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) AliyunCoverPickView *pickView;

@end

@implementation AliyunCoverPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.pickView loadThumbnailData];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:true];
}

- (void)setupSubviews {
    self.topView = [[AliyunPublishTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, StatusBarHeight+44)];
    self.topView.nameLabel.hidden = true;
    [self.topView.cancelButton setImage:nil forState:UIControlStateNormal];
    [self.topView.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.topView.finishButton setImage:nil forState:UIControlStateNormal];
    [self.topView.finishButton setTitle:@"保存" forState:UIControlStateNormal];
    self.topView.delegate = self;
    self.topView.delegate = self;
    [self.view addSubview:self.topView];
    
    CGFloat pickWith = ScreenWidth - 56;
    CGFloat factor = _outputSize.height/_outputSize.width;
    CGFloat width = ScreenWidth;
    CGFloat heigt = ScreenWidth * factor;
    CGFloat maxheight = ScreenHeight-StatusBarHeight-69-SafeBottom -pickWith/8 - 30;
    
    if(heigt>maxheight){
        heigt = maxheight;
        width = heigt / factor;
    }
    CGFloat offset = (maxheight-heigt)/2;
    
    self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-width)/2, StatusBarHeight+44+offset, width, heigt)];
    [self.view addSubview:self.coverView];
    
    
    self.pickView = [[AliyunCoverPickView alloc] initWithFrame:CGRectMake(28, ScreenHeight-SafeBottom -pickWith/8 - 30, pickWith, pickWith/8)];
    self.pickView.delegate = self;
    self.pickView.videoPath = _videoPath;
    self.pickView.outputSize = _outputSize;
    [self.view addSubview:self.pickView];
    self.view.backgroundColor = rgba(30, 30, 30, 1);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
#pragma mark - top view delegate

-(void)cancelButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)finishButtonClicked {
    _finishHandler(_coverView.image);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - pick view delegate

-(void)pickViewDidUpdateImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        _coverView.image = image;
    });
}

@end
