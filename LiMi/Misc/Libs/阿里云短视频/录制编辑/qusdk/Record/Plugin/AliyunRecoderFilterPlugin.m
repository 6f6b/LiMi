//
//  AliyunRecoderFilterPlugin.m
//  AliyunVideo
//
//  Created by mengt on 2017/4/26.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecoderFilterPlugin.h"
#import "AliyunIConfig.h"

@interface AliyunRecoderFilterPlugin()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *filterArry;
@property (nonatomic, strong) UILabel *filterLabel;
@end

@implementation AliyunRecoderFilterPlugin

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (instancetype)initWithFilterArry:(NSArray *)filterArry{
    self = [super init];
    if (self) {
        self.filterArry = [[NSMutableArray alloc]init];
        [self.filterArry addObject:@"原来"];
        [self.filterArry addObjectsFromArray:filterArry];
    }
    return self;
}

- (void)setDisPlayView:(UIView *)disPlayView{
    
    _disPlayView = disPlayView;
    
    [self addGesture];
}

- (void)addGesture{
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGesture:)];
    swipeGestureRight.delegate = self;
    [_disPlayView addGestureRecognizer:swipeGestureRight];
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftGesture:)];
    swipeGestureLeft.delegate = self;
    [_disPlayView addGestureRecognizer:swipeGestureLeft];
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
}

static int filterIdx = 0;

- (void)swipeRightGesture:(id)sender
{
    ++filterIdx;
    if (filterIdx >= [self.filterArry count]) {
        filterIdx = 0;
    }
    [self displayFilterWithIndex:filterIdx];
}

- (void)swipeLeftGesture:(id)sender
{
    --filterIdx;
    if (filterIdx < 0) {
        filterIdx = (int)[self.filterArry count] - 1;
    }
    [self displayFilterWithIndex:filterIdx];
}

- (void)displayFilterWithIndex:(int)index
{
    AliyunEffectFilter *effectFilter = [self filterAtIndex:index];
    if (_delegate) {
        [_delegate selectFilter:effectFilter index:index];
    }
    if (index == 0) {
        [self displayFilterName:@"原色"];
    } else {
        [self displayFilterName:effectFilter.name];
    }
}

- (void)displayFilterName:(NSString *)filterName {
    if (!_filterLabel) {
        [self initFilterLabel];
    }
    if (!filterName) {
        filterName = [AliyunIConfig config].noneFilterText;
    }
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animation];
    keyframeAnimation.duration = 1.f;
    keyframeAnimation.keyTimes = @[@0.0, @0.3, @0.7, @1.0];
    keyframeAnimation.values   = @[@0.0, @1.0, @1.0, @0.0];
    keyframeAnimation.fillMode = kCAFillModeForwards;
    keyframeAnimation.repeatCount = 1;
    keyframeAnimation.removedOnCompletion = NO;
    [self.filterLabel.layer addAnimation:keyframeAnimation forKey:@"opacity"];
    
    self.filterLabel.text = filterName;
}

- (void)initFilterLabel{
    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.textAlignment = 1;
    self.filterLabel.center = _disPlayView.center;
    self.filterLabel.bounds = CGRectMake(0, 0, 100, 22);
    self.filterLabel.backgroundColor = [UIColor clearColor];
    self.filterLabel.textColor = [UIColor whiteColor];
    self.filterLabel.font = [UIFont systemFontOfSize:16];
    [_disPlayView addSubview:self.filterLabel];
}

- (AliyunEffectFilter*)filterAtIndex:(NSInteger)index{
    if (index == 0) {
        AliyunEffectFilter *effectFilter = [[AliyunEffectFilter alloc]init];
        return effectFilter;
    }
    NSString *filterName = _filterArry[index];
    NSString *path = [[AliyunIConfig config] filterPath:filterName];
    AliyunEffectFilter *effectFilter = [[AliyunEffectFilter alloc] initWithFile:path];
    return effectFilter;
}

- (void)dealloc{
    NSLog(@"dealloc == ");
}

@end
