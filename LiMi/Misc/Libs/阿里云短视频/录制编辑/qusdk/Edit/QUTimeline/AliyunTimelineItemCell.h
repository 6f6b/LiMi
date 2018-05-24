//
//  AliyunTimelineItemCell.h
//  QPSDKCore
//
//  Created by Vienta on 2016/11/25.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AliyunTimelinePercent : NSObject

@property (nonatomic, assign) CGFloat leftPercent;
@property (nonatomic, assign) CGFloat rightPercent;
@property (nonatomic, strong) UIColor *color;

@end


@interface AliyunTimelineItemCell : UICollectionViewCell

@property (nonatomic, assign) CGFloat mappedBeginTime;
@property (nonatomic, assign) CGFloat mappedEndTime;
@property (nonatomic, strong) UIImageView *imageView;

- (void)setMappedBeginTime:(CGFloat)mappedBeginTime endTime:(CGFloat)mappedEndTime image:(UIImage *)image timelinePercents:(NSArray *)percents timelineFilterPercents:(NSArray *)filterPercents;

@end
