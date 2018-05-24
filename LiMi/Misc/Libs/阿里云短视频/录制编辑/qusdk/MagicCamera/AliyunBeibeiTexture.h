//
//
//  Created by dangshuai on 17/3/2.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>
@interface AliyunBeibeiTexture : NSObject

- (instancetype)initWithTextureSize:(CGSize)textureSize;
- (NSInteger)renderWithTexture:(NSInteger)textureName textureSize:(CGSize)textureSize;

- (void)tmp_init;
- (void)tmp_delete;
@end
