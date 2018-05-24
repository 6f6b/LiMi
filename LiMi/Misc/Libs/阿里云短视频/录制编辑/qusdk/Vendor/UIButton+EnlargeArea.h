//
//  UIButton+EnlargeArea.h
//  qusdk
//
//  Created by Vienta on 2017/5/19.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EnlargeArea)

- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

- (void)setDefaultEnlargeEdge;

@end
