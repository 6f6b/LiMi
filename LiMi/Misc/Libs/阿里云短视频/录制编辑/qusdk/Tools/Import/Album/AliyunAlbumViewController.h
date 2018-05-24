//
//  AliyunAlbumViewController.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/12.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPhotoLibraryManager.h"

@class AliyunAlbumModel;
typedef void(^AlbumSelectBlock)(AliyunAlbumModel *albumModel);
@interface AliyunAlbumViewController : UIViewController
@property (nonatomic, copy) NSString *albumTitle;
@property (nonatomic, assign) BOOL videoOnly;
@property (nonatomic, copy) AlbumSelectBlock selectBlock;
@property (nonatomic, assign) VideoDurationRange videoRange;
@end
