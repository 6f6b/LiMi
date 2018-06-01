//
//  AliyunPublishViewController.m
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPublishViewController.h"
#import "AliyunUploadViewController.h"
#import "AliyunCoverPickViewController.h"
#import "AliyunPublishService.h"
#import "AliyunPublishTopView.h"
#import "QUProgressView.h"
#import "AliyunPublishProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AliyunPathManager.h"
#import "AliyunPublishContentEditView.h"
#import "AliyunAuthorityChooseView.h"
#import "AliyunVisibleChooseController.h"

@interface AliyunPublishViewController () <AliyunPublishTopViewDelegate, AliyunIExporterCallback, UITextFieldDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) AliyunPublishTopView *topView;
@property (nonatomic, strong) UITextField *titleView;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIButton *pickButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) AliyunPublishProgressView *publishProgressView;
@property (nonatomic, strong) AliyunAuthorityChooseView *aliyunAuthorityChooseView;
@property (nonatomic, strong) AliyunPublishContentEditView *publishContentEditView;
@property (nonatomic, strong) UIButton *pulishButton;
@property (nonatomic, strong) UIButton *saveToLocalButton;

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL failed;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic,copy) NSString *outputPath;

@end

@implementation AliyunPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self setupSubviews];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_finished) {
        // 片尾水印
//        UIImage *image = [UIImage imageNamed:@"tail"];
//        [[AliyunPublishService service] setTailWaterMark:image frame:CGRectMake(0, 0, 84,60) duration:2];
        [[NSFileManager defaultManager] removeItemAtPath:[AliyunPathManager createExportDir] error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[AliyunPathManager createExportDir] withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *outputPath = [[[AliyunPathManager createExportDir] stringByAppendingPathComponent:[AliyunPathManager uuidString]] stringByAppendingPathExtension:@"mp4"];
        _outputPath = outputPath;
        [AliyunPublishService service].exportCallback = self;
        [[AliyunPublishService service] exportWithTaskPath:_taskPath outputPath:_outputPath];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)dealloc {
    [self removeNotifications];
}

- (void)setupSubviews {
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:self.containerView];
    // top
    self.topView = [[AliyunPublishTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, StatusBarHeight+44)];
    self.topView.nameLabel.hidden = YES;
    [self.topView.cancelButton setImage:[UIImage imageNamed:@"short_video_back"] forState:UIControlStateNormal];
    [self.topView.cancelButton setTitle:nil forState:UIControlStateNormal];
    [self.topView.finishButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.topView.finishButton setHidden:YES];
    _topView.finishButton.enabled = NO;
    self.topView.delegate = self;
    [self.containerView addSubview:self.topView];
    
    // middle
    CGFloat middleHeight = ScreenHeight *(240.0/667);
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, StatusBarHeight+44, ScreenWidth, middleHeight)];
    self.backgroundView.image = self.backgroundImage;
    self.backgroundView.userInteractionEnabled = YES;
    [self.containerView addSubview:self.backgroundView];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.backgroundView addSubview:effectView];
    effectView.frame = CGRectMake(0, 0, ScreenWidth, middleHeight);

    // pick
    CGFloat length = ScreenWidth * 3 / 4.0f;
    CGFloat ratio = _outputSize.width / _outputSize.height;
    CGFloat coverWidth, coverHeight = 0;
    coverHeight = middleHeight;
    coverWidth = middleHeight*(ScreenWidth/ScreenHeight);
//    if (ratio > 1) {
//        coverWidth = length;
//        coverHeight = coverWidth / ratio;
//    }else {
//        coverHeight = length;
//        coverWidth = length * ratio;
//    }
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, coverWidth, coverHeight)];
    self.coverImageView.center = CGPointMake(ScreenWidth/2, middleHeight/2);
    self.coverImageView.userInteractionEnabled = YES;
    [effectView.contentView addSubview:self.coverImageView];
    
    self.pickButton = [[UIButton alloc] initWithFrame:CGRectMake(0, coverHeight-36, coverWidth, 36)];
    self.pickButton.backgroundColor = rgba(0, 0, 0, 0.5);
//    self.pickButton.layer.cornerRadius = 2;
//    self.pickButton.layer.masksToBounds = YES;
    [self.pickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSAttributedString *appendString = [[NSAttributedString alloc] initWithString:@"   选择封面" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [attributedString appendAttributedString:appendString];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [AliyunImage imageNamed:@"icon_cover"];
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
    [self.pickButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    [self.pickButton setBackgroundColor:rgba(0, 0, 0, 0.7)];
    [self.pickButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pickButton addTarget:self action:@selector(pickButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.coverImageView addSubview:self.pickButton];
    self.coverImageView.hidden = YES;
    // progress
    self.publishProgressView = [[AliyunPublishProgressView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    [effectView.contentView addSubview:self.publishProgressView];
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 4)];
    self.progressView.backgroundColor = rgba(0, 0, 0, 0.6);
    self.progressView.progressTintColor = [AliyunIConfig config].timelineTintColor;
    effectView.userInteractionEnabled = YES;
    [effectView.contentView addSubview:self.progressView];
    
    // bottom
    self.publishContentEditView =  [[AliyunPublishContentEditView alloc] initWithFrame:CGRectMake(0, StatusBarHeight+44+middleHeight, ScreenWidth, 100)];
    self.publishContentEditView.placeholder = @"说点什么";
    self.publishContentEditView.maxCharacterNum = 30;
    [self.containerView addSubview:self.publishContentEditView];
//    self.titleView = [[UITextField alloc] initWithFrame:CGRectMake(20, StatusBarHeight+44+ScreenWidth, ScreenWidth-40, 54)];
//    self.titleView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"你可以在合成中添加视频描述..." attributes:@{NSForegroundColorAttributeName: rgba(188, 190, 197, 1)}];
//    self.titleView.tintColor = [AliyunIConfig config].timelineTintColor;;
//    self.titleView.textColor = [UIColor whiteColor];
//    [self.titleView setFont:[UIFont systemFontOfSize:14]];
//    self.titleView.returnKeyType = UIReturnKeyDone;
//    self.titleView.delegate = self;
//    self.titleView.backgroundColor = [AliyunIConfig config].backgroundColor;
//    [self.containerView addSubview:self.titleView];
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, StatusBarHeight+44+ScreenWidth+52, ScreenWidth-40, 1)];
//    line.backgroundColor = rgba(90, 98, 120, 1);
//    [self.containerView addSubview:line];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, StatusBarHeight+44+ScreenWidth+52+4, ScreenWidth-40, 14)];
//    label.textColor = rgba(110, 118, 139, 1);
//    label.text = @"最多不超过20个字";
//    label.font = [UIFont systemFontOfSize:10];
//    [self.containerView addSubview:label];
    
    self.aliyunAuthorityChooseView = [[AliyunAuthorityChooseView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.publishContentEditView.frame)+8, ScreenWidth, 56)];
    self.aliyunAuthorityChooseView.rightInfoLabel.text = @"所有人可见";
    [self.containerView addSubview:self.aliyunAuthorityChooseView];
    self.aliyunAuthorityChooseView.backgroundColor = rgba(43, 43, 43, 1);
    UITapGestureRecognizer *tapAliyunAuthorityChooseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAliyunAuthorityChooseView)];
    [self.aliyunAuthorityChooseView addGestureRecognizer:tapAliyunAuthorityChooseView];
    
    CGFloat pulishButtonWidth = ScreenWidth*(200.0/375);
    self.pulishButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-pulishButtonWidth-15, ScreenHeight-50-44, pulishButtonWidth, 44)];
    self.pulishButton.backgroundColor = rgba(127, 110, 241, 1);
    self.pulishButton.layer.cornerRadius = 22;
    self.pulishButton.clipsToBounds = true;
    [self.pulishButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.pulishButton addTarget:self action:@selector(pulishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.pulishButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.containerView addSubview:self.pulishButton];
    
    self.saveToLocalButton = [[UIButton alloc] initWithFrame:CGRectMake(84, ScreenHeight-69-28, 28, 28)];
    [self.saveToLocalButton setBackgroundImage:[UIImage imageNamed:@"btn_cbd"] forState:UIControlStateNormal];
    [self.containerView addSubview:self.saveToLocalButton];
    
    // vc
    self.view.backgroundColor = rgba(30, 30, 30, 1);
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)tapAliyunAuthorityChooseView{
    AliyunVisibleChooseController *visibleChooseController = [[AliyunVisibleChooseController alloc] init];
    visibleChooseController.visibleType = VisibleChooseTypeAll;
    visibleChooseController.chooseTypeBlock = ^(VisibleChooseType type){
        if(type == VisibleChooseTypeAll){
            self.aliyunAuthorityChooseView.rightInfoLabel.text = @"所有人可见";
        }
        if(type == VisibleChooseTypeFollowers){
            self.aliyunAuthorityChooseView.rightInfoLabel.text = @"粉丝可见";
        }
        if(type == VisibleChooseTypeOnlySelf){
            self.aliyunAuthorityChooseView.rightInfoLabel.text = @"自己可见";
        }
    };
    [self.navigationController pushViewController:visibleChooseController animated:true];
}

- (void)pulishButtonClicked{
    NSString *coverPath = [_taskPath stringByAppendingPathComponent:@"cover.png"];
    NSData *data = UIImagePNGRepresentation(_image);
    [data writeToFile:coverPath atomically:YES];

    AliyunUploadViewController *vc = [[AliyunUploadViewController alloc] init];
    vc.videoPath = _outputPath;
    vc.coverImagePath = coverPath;
    vc.videoSize = _outputSize;
    vc.desc = _titleView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - notification

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect end = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat containerHeight = StatusBarHeight+44+ScreenWidth+52+22;
    
    CGFloat offset = ScreenHeight-CGRectGetHeight(end)-containerHeight;
    if (offset<0) {
        [UIView animateWithDuration:duration animations:^{
            _containerView.frame = CGRectMake(0, offset, ScreenWidth, ScreenHeight);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _containerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }];
}

- (void)applicationDidBecomeActive {
    if (!_finished && !_failed) {
        [[AliyunPublishService service] exportWithTaskPath:_taskPath outputPath:_outputPath];
    }
}

#pragma mark - action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_titleView resignFirstResponder];
}

- (void)pickButtonClicked {
    AliyunCoverPickViewController *vc = [AliyunCoverPickViewController new];
    vc.outputSize = _outputSize;
    vc.videoPath = _outputPath;
    vc.finishHandler = ^(UIImage *image) {
        _image = image;
        _coverImageView.image = image;
        _backgroundView.image = image;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - util

- (UIImage *)thumbnailWithVideoPath:(NSString *)videoPath outputSize:(CGSize)outputSize{
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    AVAssetImageGenerator *_generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    _generator.maximumSize = outputSize;
    _generator.appliesPreferredTrackTransform = YES;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    CMTime time = CMTimeMake(0 * 1000, 1000);
    CGImageRef image = [_generator copyCGImageAtTime:time actualTime:NULL error:nil];
    UIImage *picture = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return picture;
}


#pragma mark - top view delegate

-(void)cancelButtonClicked {
    if (!_finished && !_failed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回编辑后将不再合成" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)finishButtonClicked {
    if (!_finished) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请等待合成完成" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (_titleView.text.length > 20) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频描述太长" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    NSString *coverPath = [_taskPath stringByAppendingPathComponent:@"cover.png"];
    NSData *data = UIImagePNGRepresentation(_image);
    [data writeToFile:coverPath atomically:YES];
    
    AliyunUploadViewController *vc = [[AliyunUploadViewController alloc] init];
    vc.videoPath = _outputPath;
    vc.coverImagePath = coverPath;
    vc.videoSize = _outputSize;
    vc.desc = _titleView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[AliyunPublishService service] cancelExport];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - export callback

- (void)exportProgress:(float)progress {
    [self.progressView setProgress:progress];
    [self.publishProgressView setProgress:progress];
}

- (void)exporterDidCancel {
    NSLog(@"export cancel");
}

-(void)exporterDidStart {
    
}

-(void)exportError:(int)errorCode {
    NSLog(@"export error");
    _failed = YES;
    [self.publishProgressView markAsFailed];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"合成失败 \n code:%d",errorCode] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });
}

-(void)exporterDidEnd:(NSString *)outputPath {
    _finished = YES;
    _progressView.hidden = YES;
    _topView.finishButton.enabled = YES;
    _image = [self thumbnailWithVideoPath:outputPath outputSize:_outputSize];
    [_publishProgressView markAsFinihed];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:outputPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                NSLog(@"视频已保存到相册");}];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _coverImageView.image = _image;
        _backgroundView.image = _image;
        _coverImageView.hidden = NO;
        _publishProgressView.hidden = YES;
    });
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
   [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
    
}
@end
