//
//  MagicCameraScrollView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/5.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MagicCameraScrollViewDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress time:(CGFloat)time;

- (void)touchesBegin;

- (void)touchesEnd;

- (void)focusItemIndex:(NSInteger)index cell:(UICollectionViewCell *)cell;

@end

@interface AliyunMagicCameraScrollView : UIView

@property (nonatomic, weak) id<MagicCameraScrollViewDelegate> delegate;
@property (nonatomic, copy) NSArray *effectItems;
@property (nonatomic, assign) CGFloat recordPercent;
@property (nonatomic,assign) NSInteger selectedIndex;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate;

- (void)hiddenScroll:(BOOL)hidden;

- (void)resetCircleView;
@end
