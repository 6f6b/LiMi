//
//  SnapchatAttachment.h
//  NIM
//
//  Created by amao on 7/2/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachmentDefines.h"

@interface NTESLiMiSystemMsgAttachment : NSObject<NIMCustomAttachment,NTESCustomAttachmentInfo>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *image;
@property (nonatomic,assign) NSInteger image_h;
@property (nonatomic,assign) NSInteger image_w;
@property (nonatomic,assign) NSInteger link_id;
@property (nonatomic,assign) NSInteger link_subid;
@property (nonatomic,assign) NSInteger link_type;
@property (nonatomic,copy) NSString *txt;
@property (nonatomic,copy) NSString *url;

@end
