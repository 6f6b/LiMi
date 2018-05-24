//
//  AliyunMediator.m
//  AliyunVideo
//
//  Created by Worthy on 2017/5/4.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMediator.h"

@implementation AliyunMediator

+ (instancetype)shared {
    static AliyunMediator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AliyunMediator alloc] init];
    });
    return instance;
}

#pragma mark - module

- (UIViewController *)recordModule {
    Class c = NSClassFromString(@"AliyunRecordParamViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}


- (UIViewController *)magicCameraModule {
    Class c = NSClassFromString(@"AliyunMagicCameraViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

- (UIViewController *)editModule {
    Class c = NSClassFromString(@"AliyunCompositionViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

- (UIViewController *)cropModule {
    Class c = NSClassFromString(@"AliyunPhotoViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

-(UIViewController *)liveModule {
    return nil;
}

-(UIViewController *)uiComponentModule {
    Class c = NSClassFromString(@"AliyunComponentViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

#pragma mark - vc

- (UIViewController *)recordViewController {
    Class c = NSClassFromString(@"AliyunRecordViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

- (UIViewController *)compositionViewController {
    Class c = NSClassFromString(@"AliyunCompositionViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

- (UIViewController *)editViewController {
    Class c = NSClassFromString(@"AliyunEditViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

- (UIViewController *)cropViewController {
    Class c = NSClassFromString(@"AliyunCropViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

- (UIViewController *)configureViewController {
    Class c = NSClassFromString(@"AliyunConfigureViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

- (UIViewController *)photoViewController {
    Class c = NSClassFromString(@"AliyunPhotoViewController");
    UIViewController *vc = (UIViewController *)[[c alloc] init];
    return vc;
}

@end
