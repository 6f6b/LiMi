//
//  AliyunRecordControlView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/18.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunRecordControlViewDelegate <NSObject>
    
    /*底部*/
- (void)bottomViewRecordVideo;
- (void)bottomViewPauseVideo;
- (void)bottomViewFinishVideo;
- (void)bottomViewDeleteFinished;
- (void)bottomViewShowLibrary;
- (void)didSelectRate:(CGFloat)rate;

    
/*顶部*/
- (void)navigationBackButtonClick;
- (void)navigationRatioDidChangedWithValue:(CGFloat)r;
- (void)navigationBeautyDidChangedStatus:(BOOL)on;
- (void)navigationCamerationPositionDidChanged:(BOOL)front;
- (NSInteger)navigationFlashModeDidChanged;
    
/*侧边*/
- (void)musicButtonClick;
@end

@interface AliyunRecordControlView : UIView
@property (nonatomic,weak) AliyunIRecorder *recoder;
@property (nonatomic,weak) AliyunClipManager *clipManager;

    /*底部工具栏*/
@property (nonatomic, assign) CGFloat minDuration;
@property (nonatomic, assign) CGFloat maxDuration;
@property (nonatomic, weak) id<AliyunRecordControlViewDelegate> delegate;

@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,weak) AliyunEffectPaster *currentEffectPaster;

@property (nonatomic,strong) UIImageView *faceDetectFaildImageView;
@property (nonatomic,strong) UILabel *faceDetectFaildInfo;
//美颜相关
@property (nonatomic,assign) int beautifyValue;
@property (nonatomic,assign) int filterIndex;

- (void)updateVideoDuration:(CGFloat)duration;
    
- (void)updateRecordStatus;
    
- (void)updateRecordTypeToEndRecord;
    
- (void)deleteLastProgress;
    
-(void)updateHeight:(CGFloat)height;
    /*侧边工具栏*/
    /*顶部工具栏*/
    - (void)setupBeautyStatus:(BOOL)isBeauty
                  flashStatus:(NSInteger)flashStatus;
    
- (void)updateNavigationStatusWithDuration:(CGFloat)duration;
    
- (void)updateNavigationStatusWithRecord:(BOOL)isRecording;
    
- (void)updateNavigationFlashStatus:(NSInteger)status;
    
@end
