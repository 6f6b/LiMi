//
//  AliyunPasterTextAttributedManager.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AliyunPasterTextAttributedManager : NSObject

- (NSAttributedString *)attributeString:(NSString *)text fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor;

- (NSAttributedString *)strokeAttributeString:(NSString *)text fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor;

- (CGSize)sizeWithCoreText:(NSAttributedString *)attributedString length:(NSUInteger)textLength width:(CGFloat)width;

@end
