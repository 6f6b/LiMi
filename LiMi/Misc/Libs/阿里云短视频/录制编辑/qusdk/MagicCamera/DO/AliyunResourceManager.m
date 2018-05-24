//
//  AliyunResourceManager.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/23.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunResourceManager.h"
#import "AliyunPathManager.h"

@implementation AliyunResourceManager

+ (NSString *)pathWithType:(AliyunResourceType)type
{
    NSString *path = [AliyunPathManager createResourceDir];

    if (type == AliyunResourceTypeFacePaster) {
        return [path stringByAppendingPathComponent:@"facepaster"];
    }
    return nil;
}

- (NSArray *)loadLocalFacePasters
{
    NSString *dir = [[self class] pathWithType:AliyunResourceTypeFacePaster];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    
    NSArray *dirEnum = [fm contentsOfDirectoryAtPath:dir error:nil];
    for (NSString *file in dirEnum) {
        NSLog(@"f~~~~~file:%@", file);
        NSString *path = [dir stringByAppendingPathComponent:file];
        NSDictionary *attribute = [fm attributesOfItemAtPath:path error:nil];
        NSString * fileType = attribute[NSFileType];
        
        if ([fileType isEqualToString:NSFileTypeDirectory]) {
            NSArray *comps = [file componentsSeparatedByString:@"-"];
            AliyunPasterInfoGroup *pasterInfoGroup = [[AliyunPasterInfoGroup alloc] init];
            pasterInfoGroup.name = comps[0];
            pasterInfoGroup.eid = [comps[1] integerValue];
            
            NSArray *pasterDirEnum = [fm contentsOfDirectoryAtPath:path error:nil];
            NSMutableArray *pasters = [[NSMutableArray alloc] init];
            
            for (NSString *pasterFile in pasterDirEnum) {
                NSString *pasterPath = [path stringByAppendingPathComponent:pasterFile];
                NSDictionary *pasterAttribute = [fm attributesOfItemAtPath:pasterPath error:nil];
                NSString * pasterFileType = pasterAttribute[NSFileType];

                if ([pasterFileType isEqualToString:NSFileTypeDirectory]) {
                    NSArray *comps2 = [pasterFile componentsSeparatedByString:@"-"];
                    AliyunPasterInfo *pasterInfo = [[AliyunPasterInfo alloc] init];
                    pasterInfo.name =  comps2[0];
                    pasterInfo.eid = [comps2[1] integerValue];
                    pasterInfo.groupId = [comps[1] integerValue];
                    pasterInfo.groupName = comps[0];
                    pasterInfo.type = 1;
                    pasterInfo.icon = [[[dir stringByAppendingPathComponent:file] stringByAppendingPathComponent:pasterFile] stringByAppendingPathComponent:@"icon.png"];
                    
                    [pasters addObject:pasterInfo];
                }
            }
            
            pasterInfoGroup.pasterList = pasters;
            [groups addObject:pasterInfoGroup];
        }
    }
    
    return groups;
}

@end
