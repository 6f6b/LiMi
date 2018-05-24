//
//  AliyunVideoBase.m
//  AliyunVideoSDK
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunVideoBase.h"
//#import "AliyunRecordViewController.h"
//#import "AliyunPhotoViewController.h"
#import "AliyunVideoUIConfig.h"
#import "AliyunVideoRecordParam.h"
#import "AliyunVideoCropParam.h"
#import "AliyunMediaConfig.h"
#import "AliyunMediator.h"

@interface AliyunVideoBase()

@property (nonatomic, strong) AliyunMediaConfig *videoConfig;

@end

@implementation AliyunVideoBase

#pragma mark - Public
+ (instancetype)shared {
    
    static AliyunVideoBase *base = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base = [[AliyunVideoBase alloc] init];
    });
    return base;
}

- (NSString *)version {
    NSString *version = (NSString *)[NSClassFromString(@"AliyunVideoSDKInfo") performSelector:@selector(version)];
    return version;
}

- (void)registerWithAliyunIConfig:(AliyunVideoUIConfig *)videoUIConfig {
    
    if (!videoUIConfig) {
        videoUIConfig = [[AliyunVideoUIConfig alloc] init];
    }
    _videoUIConfig = videoUIConfig;
    
    
    AliyunIConfig *uiConfig = [[AliyunIConfig alloc] init];
    
    uiConfig.backgroundColor            = videoUIConfig.backgroundColor;
    uiConfig.timelineBackgroundCollor   = videoUIConfig.timelineBackgroundCollor;
    uiConfig.timelineDeleteColor        = videoUIConfig.timelineDeleteColor;
    uiConfig.timelineTintColor          = videoUIConfig.timelineTintColor;
    uiConfig.durationLabelTextColor     = videoUIConfig.durationLabelTextColor;
    uiConfig.cutTopLineColor            = videoUIConfig.cutTopLineColor;
    uiConfig.cutBottomLineColor         = videoUIConfig.cutBottomLineColor;
    uiConfig.noneFilterText             = videoUIConfig.noneFilterText;
    uiConfig.hiddenDurationLabel        = videoUIConfig.hiddenDurationLabel;
    uiConfig.hiddenFlashButton          = videoUIConfig.hiddenFlashButton;
    uiConfig.hiddenBeautyButton         = videoUIConfig.hiddenBeautyButton;
    uiConfig.hiddenCameraButton         = videoUIConfig.hiddenCameraButton;
    uiConfig.hiddenImportButton         = videoUIConfig.hiddenImportButton;
    uiConfig.hiddenDeleteButton         = videoUIConfig.hiddenDeleteButton;
    uiConfig.hiddenFinishButton         = videoUIConfig.hiddenFinishButton;
    uiConfig.recordOnePart              = videoUIConfig.recordOnePart;
    uiConfig.imageBundleName            = videoUIConfig.imageBundleName;
    uiConfig.recordType                 = (AliyunIRecordActionType)videoUIConfig.recordType;
    uiConfig.showCameraButton           = videoUIConfig.showCameraButton;
    uiConfig.filterArray                = videoUIConfig.filterArray;
    uiConfig.filterBundleName           = videoUIConfig.filterBundleName;
    // 产品需要去掉这个Button
    uiConfig.hiddenRatioButton          = YES;
    [AliyunIConfig setConfig:uiConfig];
}

- (UIViewController *)createRecordViewControllerWithRecordParam:(AliyunVideoRecordParam *)recordParam {

    [self registerWithAliyunIConfig:_videoUIConfig];

    return [self recordViewControllerWithParam:recordParam];

}

- (UIViewController *)createPhotoViewControllerCropParam:(AliyunVideoCropParam *)cropParam {
    
    [self registerWithAliyunIConfig:_videoUIConfig];

    return [self photoViewControllerWithParam:cropParam];

}

#pragma mark - RecordVC delegate
- (void)recoderFinish:(UIViewController *)vc videopath:(NSString *)videoPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBase:recordCompeleteWithRecordViewController:videoPath:)]) {
        [self.delegate videoBase:self recordCompeleteWithRecordViewController:vc videoPath:videoPath];
    }
}


- (void)recordViewShowLibrary:(UIViewController *)vc {

    [AliyunIConfig config].showCameraButton = NO;
    AliyunVideoCropParam *cropParam;

    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBaseRecordViewShowLibrary:)]) {
        cropParam = [self.delegate videoBaseRecordViewShowLibrary:vc];
    }

    if (cropParam) {
        UIViewController *photoVC = [self photoViewControllerWithParam:cropParam];
        [vc.navigationController pushViewController:photoVC animated:YES];
    } else {
        UIViewController *photoVC = [[AliyunMediator shared] photoViewController];
        [photoVC setValue:self forKey:@"delegate"];
        [photoVC setValue:[vc valueForKey:@"quVideo"] forKey:@"cutInfo"];
        [vc.navigationController pushViewController:photoVC animated:YES];

    }
}

- (void)exitRecord {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBaseRecordVideoExit)]) {
        [self.delegate videoBaseRecordVideoExit];
    }
}

#pragma mark - PhotoVC delegate

- (void)recodBtnClick:(UIViewController *)vc {
    [AliyunIConfig config].hiddenImportButton = YES;
    AliyunVideoRecordParam *recordParam;

    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBasePhotoViewShowRecord:)]) {
        recordParam = [self.delegate videoBasePhotoViewShowRecord:vc];
    }

    if (recordParam) {
        UIViewController *recordVC = [self recordViewControllerWithParam:recordParam];
        [vc.navigationController pushViewController:recordVC animated:YES];
    } else {
        UIViewController *recordVC = [[AliyunMediator shared] recordViewController];
        [recordVC setValue:self forKey:@"delegate"];
        [recordVC setValue:[vc valueForKey:@"cutInfo"] forKey:@"quVideo"];
        
        //    AliyunRecordViewController *recordVC = [[AliyunRecordViewController alloc] init];
        //    recordVC.delegate = self;
        //    recordVC.quVideo = vc.cutInfo;
        [vc.navigationController pushViewController:recordVC animated:YES];
    }
}

- (void)cropFinished:(UIViewController *)cropViewController videoPath:(NSString *)videoPath sourcePath:(NSString *)sourcePath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBase:cutCompeleteWithCropViewController:videoPath:)]) {
        [self.delegate videoBase:self cutCompeleteWithCropViewController:cropViewController videoPath:videoPath];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBase:cutCompeleteWithCropViewController:videoPath:sourcePath:)]) {
        [self.delegate videoBase:self cutCompeleteWithCropViewController:cropViewController videoPath:videoPath sourcePath:sourcePath];
    }
}

- (void)cropFinished:(UIViewController *)cropViewController mediaType:(kPhotoMediaType)type photo:(UIImage *)photo videoPath:(NSString *)videoPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBase:cutCompeleteWithCropViewController:image:)]) {
        [self.delegate videoBase:self cutCompeleteWithCropViewController:cropViewController image:photo];
    }
}


- (void)backBtnClick:(UIViewController *)vc {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoBasePhotoExitWithPhotoViewController:)]) {
        [self.delegate videoBasePhotoExitWithPhotoViewController:vc];
    }
}

#pragma mark - Private
- (CGSize)outputSizeWithVideoRatio:(AliyunVideoRatio)ratio videoSize:(AliyunVideoSize)size {
    
    CGFloat videoWidth = 540;
    CGFloat videoRatio = 3.0/4.0;
    
    switch (ratio) {
        case AliyunVideoVideoRatio1To1:
            videoRatio = 1.0/1.0;
            break;
        case AliyunVideoVideoRatio3To4:
            videoRatio = 3.0/4.0;
            break;
        case AliyunVideoVideoRatio9To16:
            videoRatio = 9.0/16.0;
            break;
        default:
            break;
    }
    
    switch (size) {
        case AliyunVideoVideoSize360P:
            videoWidth = 360.0;
            break;
        case AliyunVideoVideoSize480P:
            videoWidth = 480.0;
            break;
        case AliyunVideoVideoSize540P:
            videoWidth = 540.0;
            break;
        case AliyunVideoVideoSize720P:
            videoWidth = 720.0;
            break;
        default:
            break;
    }
    
    CGFloat videoHeight = ceilf(videoWidth / videoRatio); // 视频的videoSize需为整偶数
    CGSize outputSize = CGSizeMake(videoWidth, videoHeight);
//    NSLog(@"--------videoSize:w:%f  h:%f", outputSize.width, outputSize.height);
    return outputSize;
}


- (UIViewController *)recordViewControllerWithParam:(AliyunVideoRecordParam *)recordParam {
    
    CGSize outputSize = [self outputSizeWithVideoRatio:recordParam.ratio videoSize:recordParam.size];
    AliyunMediaConfig *config = [AliyunMediaConfig recordConfigWithOutpusPath:recordParam.outputPath
                                                                   outputSize:outputSize
                                                                  minDuration:recordParam.minDuration
                                                                  maxDuration:recordParam.maxDuration
                                                                 videoQuality:(AliyunMediaQuality)recordParam.videoQuality
                                                                       encode:(AliyunVideoEncodeMode)recordParam.encodeMode
                                                                          fps:recordParam.fps
                                                                          gop:recordParam.gop];
    config.bitrate = recordParam.bitrate;
    
    UIViewController *recordVC = [[AliyunMediator shared] recordViewController];
    [recordVC setValue:self forKey:@"delegate"];
    [recordVC setValue:config forKey:@"quVideo"];
    [recordVC setValue:@(recordParam.position) forKey:@"isCameraBack"];
    [recordVC setValue:@(recordParam.torchMode) forKey:@"torchMode"];
    [recordVC setValue:@(recordParam.beautifyStatus) forKey:@"beautifyStatus"];
    [recordVC setValue:@(recordParam.beautifyValue) forKey:@"beautifyValue"];
    [recordVC setValue:@(NO) forKey:@"isSkipEditVC"];
    return recordVC;
}

- (UIViewController *)photoViewControllerWithParam:(AliyunVideoCropParam *)cropParam {
    
    CGSize outputSize = [self outputSizeWithVideoRatio:cropParam.ratio videoSize:cropParam.size];
    AliyunMediaConfig *config = [AliyunMediaConfig cutConfigWithOutputPath:cropParam.outputPath
                                                                outputSize:outputSize
                                                               minDuration:cropParam.minDuration
                                                               maxDuration:cropParam.maxDuration
                                                                   cutMode:(AliyunMediaCutMode)cropParam.cutMode
                                                              videoQuality:(AliyunMediaQuality)cropParam.videoQuality
                                                                       fps:cropParam.fps
                                                                       gop:cropParam.gop];
    config.encodeMode = (AliyunVideoEncodeMode)cropParam.encodeMode;
    config.backgroundColor = cropParam.fillBackgroundColor;
    config.videoOnly = cropParam.videoOnly;
    config.gpuCrop = cropParam.gpuCrop;
    config.bitrate = cropParam.bitrate;
    UIViewController *photoVC = [[AliyunMediator shared] photoViewController];
    [photoVC setValue:self forKey:@"delegate"];
    [photoVC setValue:config forKey:@"cutInfo"];

    return photoVC;
}


@end
