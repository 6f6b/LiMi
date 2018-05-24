//
//  AliyunIConfig.h
//  AliyunVideo
//
//  Created by mengt on 2017/4/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunIConfig : NSObject


typedef NS_ENUM(NSInteger, AliyunIRecordActionType) {
    AliyunIRecordActionTypeCombination = 0,
    AliyunIRecordActionTypeClick,
    AliyunIRecordActionTypeHold
};



@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UIColor *timelineTintColor;

@property (nonatomic, strong) UIColor *timelineBackgroundCollor;

@property (nonatomic, strong) UIColor *timelineDeleteColor;

@property (nonatomic, strong) UIColor *durationLabelTextColor;

@property (nonatomic, strong) UIColor *cutBottomLineColor;

@property (nonatomic, strong) UIColor *cutTopLineColor;

@property (nonatomic,strong) NSString *noneFilterText;

@property (nonatomic, assign) BOOL hiddenDurationLabel;

@property (nonatomic, assign) BOOL hiddenRatioButton;

@property (nonatomic, assign) BOOL hiddenBeautyButton;

@property (nonatomic, assign) BOOL hiddenCameraButton;

@property (nonatomic, assign) BOOL hiddenFlashButton;

@property (nonatomic, assign) BOOL hiddenImportButton;

@property (nonatomic, assign) BOOL hiddenDeleteButton;

@property (nonatomic, assign) BOOL hiddenFinishButton;

@property (nonatomic, assign) BOOL recordOnePart;

@property (nonatomic, assign) BOOL showCameraButton;

@property (nonatomic, strong) NSString *imageBundleName;

@property (nonatomic, strong) NSString *filterBundleName;

@property (nonatomic, assign) AliyunIRecordActionType recordType;

@property (nonatomic, strong) NSArray *filterArray;

+ (AliyunIConfig *)config;

+ (void)setConfig:(AliyunIConfig *)c;

- (NSString *)imageName:(NSString *)imageName;

- (NSString *)filterPath:(NSString *)filterName;

@end
