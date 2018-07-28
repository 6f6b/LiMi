//
//  QURecordParamViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordParamViewController.h"
#import "AliyunRecordParamTableViewCell.h"

#if SDK_VERSION == SDK_VERSION_BASE
#import <AliyunVideoSDK/AliyunVideoRecordParam.h>

#else
#import "AliyunVideoRecordParam.h"
#import "AliyunMediaConfig.h"
#endif


@interface AliyunRecordParamViewController ()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

#if SDK_VERSION == SDK_VERSION_CUSTOM
@property (nonatomic, strong) AliyunMediaConfig *quVideo;
#else
@property (nonatomic, strong) AliyunVideoRecordParam *quVideo;
#endif

@property (nonatomic, assign) CGFloat videoOutputWidth;
@property (nonatomic, assign) CGFloat videoOutputRatio;

@end

@implementation AliyunRecordParamViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupParamData];
    [_tableView reloadData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)];
    [self.tableView addGestureRecognizer:tapGesture];
    
#if SDK_VERSION == SDK_VERSION_CUSTOM
    _quVideo = [[AliyunMediaConfig alloc] init];
    _quVideo.outputSize = CGSizeMake(540, 720);
    _quVideo.minDuration = 2;
    _quVideo.maxDuration = FIRST_LEVEL_RECORD_TIME;
#else
    _quVideo = [[AliyunVideoRecordParam alloc] init];
    _quVideo.ratio = AliyunVideoVideoRatio3To4;
    _quVideo.size = AliyunVideoVideoSize540P;
    _quVideo.minDuration = 2;
    _quVideo.maxDuration = FIRST_LEVEL_RECORD_TIME;
    _quVideo.position = AliyunCameraPositionFront;
    _quVideo.beautifyStatus = YES;
    _quVideo.beautifyValue = 100;
    _quVideo.torchMode = AliyunCameraTorchModeOff;
    _quVideo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_save.mp4"];

#endif
    
    self.videoOutputRatio = 0.75;
    self.videoOutputWidth = 540;
}

- (void)hiddenKeyboard:(id)sender {
    [self.view endEditing:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AliyunRecordParamCellModel *model = _dataArray[indexPath.row];
    if (model) {
        NSString *identifier = model.reuseId;
        AliyunRecordParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[AliyunRecordParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell configureCellModel:model];
        return cell;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 50, 0, 100, 44)];
    [button setTitle:@"启动录制" forState:0];
    [button addTarget:self action:@selector(toRecordView) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = RGBToColor(240, 84, 135);
    [view addSubview:button];
    return view;
}

- (void)setupParamData {
    
        AliyunRecordParamCellModel *cellModel0 = [[AliyunRecordParamCellModel alloc] init];
        cellModel0.title = @"码率";
        cellModel0.placeHolder = @"";
        cellModel0.reuseId = @"cellInput";
        cellModel0.valueBlock = ^(int value){
            _quVideo.bitrate = value;
        };

    
    AliyunRecordParamCellModel *cellModel1 = [[AliyunRecordParamCellModel alloc] init];
    cellModel1.title = @"最小时长";
    cellModel1.placeHolder = @"最小时长大于0，默认值2s";
    cellModel1.reuseId = @"cellInput";
    cellModel1.valueBlock = ^(int value){
        _quVideo.minDuration = value;
    };
    
    AliyunRecordParamCellModel *cellModel2 = [[AliyunRecordParamCellModel alloc] init];
    cellModel2.title = @"最大时长";
    cellModel2.placeHolder = @"建议不超过300S，默认值30s";
    cellModel2.reuseId = @"cellInput";
    cellModel2.valueBlock = ^(int value){
        _quVideo.maxDuration = value;
    };
    
    AliyunRecordParamCellModel *cellModel3 = [[AliyunRecordParamCellModel alloc] init];
    cellModel3.title = @"关键帧间隔";
    cellModel3.placeHolder = @"建议1-300，默认5";
    cellModel3.reuseId = @"cellInput";
    cellModel3.valueBlock = ^(int value) {
        _quVideo.gop = value;
    };
    
    AliyunRecordParamCellModel *cellModel4 = [[AliyunRecordParamCellModel alloc] init];
    cellModel4.title = @"视频质量";
    cellModel4.placeHolder = @"高";
    cellModel4.reuseId = @"cellSilder";
    cellModel4.defaultValue = 0.25;
    cellModel4.valueBlock = ^(int value){
        _quVideo.videoQuality = value;
    };
    
    AliyunRecordParamCellModel *cellModel5 = [[AliyunRecordParamCellModel alloc] init];
    cellModel5.title = @"视频比例";
    cellModel5.placeHolder = @"3:4";
    cellModel5.reuseId = @"cellSilder";
    cellModel5.defaultValue = 0.6;
    cellModel5.ratioBack = ^(CGFloat videoRatio){
        self.videoOutputRatio = videoRatio;
    };
    
    AliyunRecordParamCellModel *cellModel6 = [[AliyunRecordParamCellModel alloc] init];
    cellModel6.title = @"分辨率";
    cellModel6.placeHolder = @"540P";
    cellModel6.reuseId = @"cellSilder";
    cellModel6.defaultValue = 0.75;
    cellModel6.sizeBlock = ^(CGFloat videoWidth){
        self.videoOutputWidth = videoWidth;
    };
    
    
    _dataArray = @[cellModel0,cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6];
}

// 根据调节结果更新videoSize
#if SDK_VERSION == SDK_VERSION_CUSTOM
- (void)updatevideoOutputVideoSize {
    
    CGFloat width = self.videoOutputWidth;
    CGFloat height = ceilf(self.videoOutputWidth / self.videoOutputRatio); // 视频的videoSize需为整偶数
    _quVideo.outputSize = CGSizeMake(width, height);
    NSLog(@"videoSize:w:%f  h:%f", _quVideo.outputSize.width, _quVideo.outputSize.height);
}
#endif

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view resignFirstResponder];
}

- (IBAction)buttonBackClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)toRecordView {
    [self.view endEditing:YES];
    
#if SDK_VERSION == SDK_VERSION_CUSTOM
    [self updatevideoOutputVideoSize];
#else
    if (self.videoOutputRatio == 0.5625) {
        _quVideo.ratio = AliyunVideoVideoRatio9To16;
    }else if (self.videoOutputRatio == 0.75) {
        _quVideo.ratio = AliyunVideoVideoRatio3To4;
    } else {
        _quVideo.ratio = AliyunVideoVideoRatio1To1;
    }

#endif

    
    if (_quVideo.maxDuration <= _quVideo.minDuration) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不得小于最小时长" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (_delegate) {
        [_delegate toRecordViewControllerWithMediaConfig:_quVideo];
    }
}
@end
