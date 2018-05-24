//
//  AliyunRecoderFilterPlugin.h
//  AliyunVideo
//
//  Created by mengt on 2017/4/26.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunEffectFilter.h>

@protocol AliyunRecoderFilterPluginDelegate <NSObject>

- (void)selectFilter:(AliyunEffectFilter*)filter index:(NSInteger)index;

@end

@interface AliyunRecoderFilterPlugin : NSObject
@property (nonatomic, strong) UIView *disPlayView;
@property (nonatomic, weak) id<AliyunRecoderFilterPluginDelegate> delegate;
- (instancetype)initWithFilterArry:(NSArray *)filterArry;


@end
