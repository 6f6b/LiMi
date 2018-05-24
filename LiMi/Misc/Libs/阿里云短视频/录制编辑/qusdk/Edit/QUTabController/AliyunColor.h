//
//  AliyunColor.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface AliyunColor : NSObject

@property (nonatomic, assign) CGFloat tR;
@property (nonatomic, assign) CGFloat tG;
@property (nonatomic, assign) CGFloat tB;
@property (nonatomic, assign) CGFloat sR;
@property (nonatomic, assign) CGFloat sG;
@property (nonatomic, assign) CGFloat sB;
@property (nonatomic, assign) BOOL isStroke;

- (id)initWithDict:(NSDictionary *)dict;

- (id)initWithColor:(UIColor *)color strokeColor:(UIColor *)strokeColor stoke:(BOOL)stroke;

@end
