//
//  AliyunRootViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRootViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#if SDK_VERSION == SDK_VERSION_BASE
#import <AliyunVideoSDK/AliyunVideoSDK.h>
#else
#import "AliyunMediator.h"
#import "AliyunMediaConfig.h"
#import "AliyunVideoBase.h"
#import "AliyunVideoUIConfig.h"
#import "AliyunVideoCropParam.h"
#endif

#define DEBUG_TEST 0

typedef NS_OPTIONS(NSUInteger, DebugModuleOption) {
    DebugModuleOptionVideo = 1 << 5,
    DebugModuleOptionMagicCamera = 1 << 4,
    DebugModuleOptionImportEdit = 1 << 3,
    DebugModuleOptionImportClip = 1 << 2,
    DebugModuleOptionLive = 1 << 1,
    DebugModuleOptionComposition = 1 << 0,
};

@interface AliyunRootViewController ()

@property (assign, nonatomic) DebugModuleOption moduleOption;
@property (assign, nonatomic) BOOL isClipConfig;
@property (assign, nonatomic) BOOL isPhotoToRecord;
@end

@implementation AliyunRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moduleOption = DebugModule;
    
    
#if (SDK_VERSION == SDK_VERSION_BASE || SDK_VERSION == SDK_VERSION_STANDARD)
    [self setupSDKBaseVersionUI];
#else
    [self setupSDKUI];
#endif
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[self imageNamed:@"root_bg"]];
    image.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:image];
    [self setupButtons];
}

- (void)setupButtons
{

    CGFloat width = 360;
    CGFloat height = 480;
    
    CGFloat gapWidth = width/3;
    CGFloat gapHeight = height/4;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth-width)/2, (ScreenHeight-height)/2, width, height)];
    [self.view addSubview:contentView];
    int count = 0;
    for (int i = 0; i < 6; i++) {
        BOOL shouldAdd = self.moduleOption & 1 << (5-i);
        if (shouldAdd) {
            UIView *view = [self createElementWithIndex:i];
            int column = count % 2 + 1;
            int row = count / 2 + 1;
            [contentView addSubview:view];
            view.center = CGPointMake(gapWidth*column, gapHeight*row);
            count++;
        }
        
    }
}

-(UIView *)createElementWithIndex:(int)index {
    CGFloat width = 80 ,height = 100;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    [view addSubview:button];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, width, width, height-width)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    
    switch (index) {
        case 0:
            [button addTarget:self action:@selector(buttonVideoClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[self imageNamed:@"vedio"] forState:UIControlStateNormal];
            [label setText:NSLocalizedString(@"拍摄", nil)];
            break;
        case 1:
            [button addTarget:self action:@selector(butttonMaigcCameraClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[self imageNamed:@"camerra"] forState:UIControlStateNormal];
            [label setText:NSLocalizedString(@"魔法相机", nil)];
            break;
        case 2:
            [button addTarget:self action:@selector(buttonImportEditClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[self imageNamed:@"import_edit"] forState:UIControlStateNormal];
            [label setText:NSLocalizedString(@"导入编辑", nil)];
            break;
        case 3:
            [button addTarget:self action:@selector(buttonCompositionClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[self imageNamed:@"import_cut"] forState:UIControlStateNormal];
            [label setText:NSLocalizedString(@"导入裁剪", nil)];
            break;
        case 4:
            [button setBackgroundImage:[self imageNamed:@"live"] forState:UIControlStateNormal];
            [label setText:NSLocalizedString(@"直播", nil)];
            break;
        case 5:
            [button addTarget:self action:@selector(buttonComponentClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[self imageNamed:@"others"] forState:UIControlStateNormal];
            [label setText:NSLocalizedString(@"其他", nil)];
            break;
        default:
            break;
    }
    return view;
}



#if (SDK_VERSION == SDK_VERSION_BASE || SDK_VERSION == SDK_VERSION_STANDARD)
- (void)setupSDKBaseVersionUI {
    AliyunVideoUIConfig *config = [[AliyunVideoUIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.cutTopLineColor = [UIColor redColor];
    config.cutBottomLineColor = [UIColor redColor];
    config.noneFilterText = @"无滤镜";
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"炽黄",@"粉桃",@"海蓝",@"红润",@"灰白",@"经典",@"麦茶",@"浓烈",@"柔柔",@"闪耀",@"鲜果",@"雪梨",@"阳光",@"优雅",@"朝阳",@"波普",@"光圈",@"海盐",@"黑白",@"胶片",@"焦黄",@"蓝调",@"迷糊",@"思念",@"素描",@"鱼眼",@"马赛克",@"模糊"];
    config.imageBundleName = @"QPSDK";
    config.filterBundleName = @"FilterResource";
    config.recordType = AliyunVideoRecordTypeCombination;
    config.showCameraButton = YES;
    
    [[AliyunVideoBase shared] registerWithAliyunIConfig:config];
}
#else
- (void)setupSDKUI {
    
    AliyunIConfig *config = [[AliyunIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"filter/炽黄",@"filter/粉桃",@"filter/海蓝",@"filter/红润",@"filter/灰白",@"filter/经典",@"filter/麦茶",@"filter/浓烈",@"filter/柔柔",@"filter/闪耀",@"filter/鲜果",@"filter/雪梨",@"filter/阳光",@"filter/优雅",@"filter/朝阳",@"filter/波普",@"filter/光圈",@"filter/海盐",@"filter/黑白",@"filter/胶片",@"filter/焦黄",@"filter/蓝调",@"filter/迷糊",@"filter/思念",@"filter/素描",@"filter/鱼眼",@"filter/马赛克",@"filter/模糊"];
    config.imageBundleName = @"QPSDK";
    config.recordType = AliyunIRecordActionTypeCombination;
    config.filterBundleName = nil;
    config.showCameraButton = YES;
    
    [AliyunIConfig setConfig:config];
}

#endif

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)clipLayerBoundsWithButton:(UIButton *)button {
    button.layer.cornerRadius = 25;
    button.layer.masksToBounds = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tool

- (UIImage *)imageNamed:(NSString *)name {
#if SDK_VERSION == SDK_VERSION_BASE
    NSString *path = [NSString stringWithFormat:@"%@.bundle/%@",[AliyunVideoBase shared].videoUIConfig.imageBundleName,name];
    return [UIImage imageNamed:path];
#else
    return [AliyunImage imageNamed:name];
#endif
}

#pragma mark - action

- (IBAction)buttonVideoClick:(id)sender {
#if SDK_VERSION != SDK_VERSION_BASE
    [AliyunIConfig config].hiddenImportButton = NO;
#endif
    UIViewController *vc = [[AliyunMediator shared] recordModule];
    [vc setValue:self forKey:@"delegate"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)butttonMaigcCameraClick:(id)sender {
    UIViewController *vc = [[AliyunMediator shared] magicCameraModule];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonImportEditClick:(id)sender {
    _isClipConfig = NO;
    UIViewController *vc = [[AliyunMediator shared] configureViewController];
    [vc setValue:self forKey:@"delegate"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonCompositionClick:(id)sender {
    _isClipConfig = YES;
    UIViewController *vc = [[AliyunMediator shared] configureViewController];
    [vc setValue:self forKey:@"delegate"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonComponentClick:(id)sender {
     UIViewController *vc = [[AliyunMediator shared] uiComponentModule];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - RecordParamViewControllerDelegate
- (void)toRecordViewControllerWithMediaConfig:(id)config {
#if SDK_VERSION == SDK_VERSION_CUSTOM
    UIViewController *recordVC = [[AliyunMediator shared] recordViewController];
    [recordVC setValue:self forKey:@"delegate"];
    [recordVC setValue:config forKey:@"quVideo"];
    [recordVC setValue:@(YES) forKey:@"isSkipEditVC"];
    [self.navigationController pushViewController:recordVC animated:YES];
#else
    UIViewController *recordViewController = [[AliyunVideoBase shared] createRecordViewControllerWithRecordParam:(AliyunVideoRecordParam*)config];
    [AliyunVideoBase shared].delegate = (id)self;
    [self.navigationController pushViewController:recordViewController animated:YES];
#endif
}

#pragma mark - ConfigureViewControllerdelegate

- (void)configureDidFinishWithMedia:(AliyunMediaConfig *)mediaConfig {
    if (_isClipConfig) {
#if SDK_VERSION != SDK_VERSION_BASE
        [AliyunIConfig config].showCameraButton = YES;
#endif
        UIViewController *vc = [[AliyunMediator shared] cropModule];
        [vc setValue:mediaConfig forKey:@"cutInfo"];
        [vc setValue:self forKey:@"delegate"];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        UIViewController *vc = [[AliyunMediator shared] editModule];
        [vc setValue:mediaConfig forKey:@"compositionConfig"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - PhotoViewControllerDelgate
- (void)recodBtnClick:(UIViewController *)vc {
#if SDK_VERSION != SDK_VERSION_BASE
    [AliyunIConfig config].hiddenImportButton = YES;
#endif
    self.isPhotoToRecord = YES;
    UIViewController *recordVC = [[AliyunMediator shared] recordViewController];
    [recordVC setValue:self forKey:@"delegate"];
    [recordVC setValue:[vc valueForKey:@"cutInfo"] forKey:@"quVideo"];
    [recordVC setValue:@(NO) forKey:@"isSkipEditVC"];
    [self.navigationController pushViewController:recordVC animated:YES];
}

- (void)videoBase:(AliyunVideoBase *)base cutCompeleteWithCropViewController:(UIViewController *)cropVC image:(UIImage *)image {
    //裁剪图片
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)cropFinished:(UIViewController *)cropViewController videoPath:(NSString *)videoPath sourcePath:(NSString *)sourcePath {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"裁剪完成，保存到相册失败");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪完成" message:@"已保存到手机相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (void)cropFinished:(UIViewController *)cropViewController mediaType:(kPhotoMediaType)type photo:(UIImage *)photo videoPath:(NSString *)videoPath {
    if (type == kPhotoMediaTypePhoto) {
        UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error != NULL){
        NSLog(@"裁剪完成，保存到相册失败");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪完成" message:@"已保存到手机相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    });
}

- (void)backBtnClick:(UIViewController *)vc {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RecordViewControllerDelegate 
- (void)exitRecord {
    if (self.isPhotoToRecord) {
        self.isPhotoToRecord = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recoderFinish:(UIViewController *)vc videopath:(NSString *)videoPath {
    
    if (self.isPhotoToRecord) {
        self.isPhotoToRecord = NO;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"录制完成，保存到相册失败");
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
        return;
    }
    UIViewController *editVC = [[AliyunMediator shared] editViewController];
    NSString *outputPath = [[vc valueForKey:@"recorder"] valueForKey:@"taskPath"];
    [editVC setValue:outputPath forKey:@"taskPath"];
    [editVC setValue:[vc valueForKey:@"quVideo"] forKey:@"config"];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)recordViewShowLibrary:(UIViewController *)vc {
#if SDK_VERSION != SDK_VERSION_BASE
    [AliyunIConfig config].showCameraButton = NO;
#endif
    UIViewController *compositionVC = [[AliyunMediator shared] compositionViewController];
    AliyunMediaConfig *mediaConfig = [[AliyunMediaConfig alloc] init];
    mediaConfig.fps = 25;
    mediaConfig.gop = 5;
    mediaConfig.videoQuality = 1;
    mediaConfig.cutMode = AliyunMediaCutModeScaleAspectFill;
    mediaConfig.encodeMode = AliyunEncodeModeHardH264;
    mediaConfig.outputSize = CGSizeMake(540, 720);
    mediaConfig.videoOnly = NO;
    [compositionVC setValue:mediaConfig forKey:@"compositionConfig"];
    [self.navigationController pushViewController:compositionVC animated:YES];

}

#pragma mark - AliyunVideoBaseDelegate
#if (SDK_VERSION == SDK_VERSION_BASE || SDK_VERSION == SDK_VERSION_STANDARD)
-(void)videoBaseRecordVideoExit {
    NSLog(@"退出录制");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)videoBase:(AliyunVideoBase *)base recordCompeleteWithRecordViewController:(UIViewController *)recordVC videoPath:(NSString *)videoPath {
    NSLog(@"录制完成  %@", videoPath);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [recordVC.navigationController popViewControllerAnimated:YES];
                                    });
                                }];
}

- (AliyunVideoCropParam *)videoBaseRecordViewShowLibrary:(UIViewController *)recordVC {
    
    NSLog(@"录制页跳转Library");
    // 可以更新相册页配置
    AliyunVideoCropParam *mediaInfo = [[AliyunVideoCropParam alloc] init];
    mediaInfo.minDuration = 2.0;
    mediaInfo.maxDuration = 10.0*60;
    mediaInfo.fps = 25;
    mediaInfo.gop = 5;
    mediaInfo.videoQuality = 1;
    mediaInfo.size = AliyunVideoVideoSize540P;
    mediaInfo.ratio = AliyunVideoVideoRatio3To4;
    mediaInfo.cutMode = AliyunVideoCutModeScaleAspectFill;
    mediaInfo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cut_save.mp4"];
    return mediaInfo;
    
}

// 裁剪
- (void)videoBase:(AliyunVideoBase *)base cutCompeleteWithCropViewController:(UIViewController *)cropVC videoPath:(NSString *)videoPath {
    
    NSLog(@"裁剪完成  %@", videoPath);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [cropVC.navigationController popViewControllerAnimated:YES];
                                    });
                                }];
    
}

- (AliyunVideoRecordParam *)videoBasePhotoViewShowRecord:(UIViewController *)photoVC {
    
    NSLog(@"跳转录制页");
    return nil;
}

- (void)videoBasePhotoExitWithPhotoViewController:(UIViewController *)photoVC {
    
    NSLog(@"退出相册页");
    [photoVC.navigationController popViewControllerAnimated:YES];
}
#endif

@end
