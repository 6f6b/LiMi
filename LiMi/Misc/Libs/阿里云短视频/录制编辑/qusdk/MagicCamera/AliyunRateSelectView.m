//
//  AliyunRateSelectView.m
//  qusdk
//
//  Created by Worthy on 2017/6/19.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRateSelectView.h"

@implementation AliyunRateSelectView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = rgba(0,0,0,0.4);
//    self.tintColor = rgba(255,255,255,0.6);
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:15]}
                           forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:15]}
                        forState:UIControlStateSelected];
    
    [self setBackgroundImage:[self imageWithBgColor:rgba(255,255,255,0.5)]
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                        forState:UIControlStateSelected];
    [self setBackgroundImage:[self imageWithBgColor:rgba(255,255,255,1)]
                    forState:UIControlStateSelected
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[self imageWithBgColor:rgba(0,194,221,1)]
                    forState:UIControlStateHighlighted
                  barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:[self imageWithBgColor:rgba(255,255,255,0.5)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.layer.borderWidth = 0;
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImage *)imageWithBgColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
