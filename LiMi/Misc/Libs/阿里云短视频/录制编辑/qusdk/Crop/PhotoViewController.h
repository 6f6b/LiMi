//
//  PhotoViewController.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"
#import "AliyunPhotoViewController.h"

@protocol PhotoViewControllerDelegate <NSObject>
- (void)cancelButtonClicked;
- (void)recodBtnClick;
@end

@interface PhotoViewController : UIViewController

//@property (nonatomic, assign) BOOL cutMode;
//@property (nonatomic, assign) CGSize destSize;
//@property (nonatomic, assign) int videoQuality;
//@property (nonatomic, assign) int fps;
//@property (nonatomic, assign) int gop;

@property (nonatomic,assign) int minDuration;
@property (nonatomic,assign) int maxDuration;

//挑战
@property (nonatomic,assign) NSInteger challengeId;
@property (nonatomic,copy) NSString *challengeName;
@property (nonatomic, weak) id<PhotoViewControllerDelegate> delegate;
@end
