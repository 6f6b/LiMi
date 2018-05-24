//
//  AliyunColor.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunColor.h"

@implementation AliyunColor

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.tR = [[dict objectForKey:@"tR"] floatValue];
        self.tG = [[dict objectForKey:@"tG"] floatValue];
        self.tB = [[dict objectForKey:@"tB"] floatValue];
        self.sR = [[dict objectForKey:@"sR"] floatValue];
        self.sG = [[dict objectForKey:@"sG"] floatValue];
        self.sB = [[dict objectForKey:@"sB"] floatValue];
        self.isStroke = [[dict objectForKey:@"isStroke"] boolValue];
    }
    return self;
}

- (id)initWithColor:(UIColor *)color strokeColor:(UIColor *)strokeColor stoke:(BOOL)stroke
{
    if (self = [super init]) {
        self.isStroke = stroke;
        
        CGFloat colorComponents[3];
        [self getRGBComponents:colorComponents forColor:color];
        self.tR = colorComponents[0];
        self.tG = colorComponents[1];
        self.tB = colorComponents[2];
        
        CGFloat strokeColorComponents[3];
        [self getRGBComponents:strokeColorComponents forColor:strokeColor];
        self.sR = strokeColorComponents[0];
        self.sG = strokeColorComponents[1];
        self.sB = strokeColorComponents[2];
    }
    return self;
}

- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] *1.0;
    }
}

@end
