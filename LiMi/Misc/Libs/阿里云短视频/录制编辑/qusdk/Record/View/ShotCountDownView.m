//
//  ShotCountDownView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/18.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "ShotCountDownView.h"
@interface ShotCountDownView()
    @property (nonatomic,weak) UILabel *timeLabel;
    @property (nonatomic,strong) NSTimer *timer;
    @property (nonatomic,assign) int time;
@end
@implementation ShotCountDownView
    - (instancetype)init{
        if (self = [self initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)]){
            
        }
        return self;
    }
    
    - (instancetype)initWithFrame:(CGRect)frame{
        if (self=[super initWithFrame:frame]){
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            self.timeLabel = timeLabel;
//            [self.timeLabel sizeToFit];
            self.timeLabel.center = self.center;
            self.timeLabel.font = [UIFont systemFontOfSize:150 weight:UIFontWeightBold];
            self.timeLabel.textColor = UIColor.whiteColor;
            self.timeLabel.backgroundColor = UIColor.greenColor;
            [self addSubview:self.timeLabel];
            self.backgroundColor = rgba(255, 0, 0, 0.4);
        }
        return self;
    }
    
- (void)showWith:(int)time{
    self.time = time;
    [UIApplication.sharedApplication.keyWindow addSubview:self];
    self.timeLabel.text = [NSString stringWithFormat:@"%d",self.time];
    [self.timeLabel sizeToFit];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
        self.time -= 1;
        if(self.time <= 0){
                if(self.completeBlock != nil){
                    self.completeBlock();
                }
                [self.timer invalidate];
                 [self removeFromSuperview];
            
             }else{
                 self.timeLabel.text = [NSString stringWithFormat:@"%d",self.time];
             }
    }];
}


@end
