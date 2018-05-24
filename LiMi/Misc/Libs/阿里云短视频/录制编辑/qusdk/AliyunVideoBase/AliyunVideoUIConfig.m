//
//  AliyunVideoUIConfig.m
//  AliyunVideoSDK
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunVideoUIConfig.h"

@implementation AliyunVideoUIConfig

- (instancetype)init {
    self = [super init];
    if (!self) {
        return self;
    }
    
    _backgroundColor = RGBToColor(35, 42, 66);
    _timelineBackgroundCollor = [UIColor whiteColor];
    _timelineDeleteColor = [UIColor redColor];
    _timelineTintColor = RGBToColor(239, 75, 129);
    _durationLabelTextColor = [UIColor redColor];
    _cutTopLineColor = [UIColor redColor];
    _cutBottomLineColor = [UIColor redColor];
    _noneFilterText = @"无滤镜";
    _hiddenDurationLabel = NO;
    _hiddenFlashButton = NO;
    _hiddenBeautyButton = NO;
    _hiddenCameraButton = NO;
    _hiddenImportButton = NO;
    _hiddenDeleteButton = NO;
    _hiddenFinishButton = NO;
    _recordOnePart = NO;
    _filterArray = [[NSArray alloc] init];
    _imageBundleName = @"image";
    _filterBundleName = @"FilterResource";
    _recordType = AliyunVideoRecordTypeCombination;
    _showCameraButton = YES;
    
    return self;
}


@end
