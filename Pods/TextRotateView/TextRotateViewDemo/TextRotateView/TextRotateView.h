//
//  TextRotateView.h
//  TextRotateViewDemo
//
//  Created by dev.liufeng on 2018/6/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextRotateView : UICollectionView
/**
 旋转速度，默认值20
 */
@property (nonatomic,assign) CGFloat rotateRate;

/**
 文本水平间距，默认值 10
 */
@property (nonatomic,assign) CGFloat horizontalSpacing;
/**
 初始化一个TextRotateView实例

 @param frame 视图frame
 @param textModels 文本模型数组
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame textModels:(NSArray *)textModels;


/**
 启动
 */
- (void)start;

/**
 停止
 */
- (void)stop;

/**
 暂停
 */
- (void)pause;

/**
 恢复
 */
- (void)resume;
@end
