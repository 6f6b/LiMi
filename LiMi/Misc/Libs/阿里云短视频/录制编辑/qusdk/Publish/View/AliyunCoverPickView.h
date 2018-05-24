//
//  AliyunCoverPickView.h
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AliyunCoverPickViewDelegate
- (void)pickViewDidUpdateImage:(UIImage *)image;
@end

@interface AliyunCoverPickView : UIView
@property (nonatomic, weak) id<AliyunCoverPickViewDelegate> delegate;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) CGSize outputSize;
@property (nonatomic, strong) UIImage *selectedImage;
- (void)loadThumbnailData;
@end
