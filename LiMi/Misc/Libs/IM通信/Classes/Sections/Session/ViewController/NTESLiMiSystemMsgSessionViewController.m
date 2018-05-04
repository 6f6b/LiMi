//
//  NTESLiMiSystemMsgSessionViewController.m
//  LiMi
//
//  Created by dev.liufeng on 2018/4/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "NTESLiMiSystemMsgSessionViewController.h"
#import "NTESLiMiSystemMsgAttachment.h"
#import "LiMi-Swift.h"
#import "NTESGalleryViewController.h"

@interface NTESLiMiSystemMsgSessionViewController ()

@end

@implementation NTESLiMiSystemMsgSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItems = nil;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotificationWith:) name:@"DEAL_TAP_LINK" object:nil];
//    [userInfo setObject:self.model forKey:@"NIMMessageModel"];
//    [NSNotificationCenter.defaultCenter postNotificationName:@"DEAL_TAP_LINK" object:nil userInfo:userInfo];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedTapImageNotificationWith:) name:@"DEAL_TAP_IMAGE" object:nil];
//    [userInfo setObject:self.model.message  forKey:@"NIMMessageModel"];
//    [NSNotificationCenter.defaultCenter postNotificationName:@"DEAL_TAP_IMAGE" object:nil userInfo:userInfo];
}

- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)receivedTapImageNotificationWith:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    NIMMessageModel *messageModel = [dic objectForKey:@"NIMMessageModel"];
    NIMCustomObject * customObject     = (NIMCustomObject*)messageModel.message.messageObject;
    NTESLiMiSystemMsgAttachment *attachment = (NTESLiMiSystemMsgAttachment *)customObject.attachment;
    //查看图片
        NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
        item.thumbPath      = [attachment image];
        item.imageURL       = [attachment image];
        item.itemId         = [messageModel.message messageId];
    //
        NIMSession *session = [self isMemberOfClass:[NTESSessionViewController class]]? self.session : nil;
        NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item session:session];
        [self.navigationController pushViewController:vc animated:YES];
    //    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
    //        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
    //        __weak typeof(self) wself = self;
    //        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
    //            if (!error) {
    //                [wself uiUpdateMessage:message];
    //            }
    //        }];
    //    }
}

- (void)receiveNotificationWith:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    NIMMessageModel *messageModel = [dic objectForKey:@"NIMMessageModel"];
    NSString *linkURL = [dic objectForKey:@"LinkURL"];
    if(messageModel != nil){
        NIMCustomObject * customObject     = (NIMCustomObject*)messageModel.message.messageObject;
        NTESLiMiSystemMsgAttachment *attachment = (NTESLiMiSystemMsgAttachment *)customObject.attachment;
        if(attachment.url != nil){
            NTESLiMiWebController *webController = [[NTESLiMiWebController alloc] init];
            webController.url = attachment.url;
            [self.navigationController pushViewController:webController animated:true];
            return;
        }
        if(attachment.url == nil){
            //动态
            if(attachment.link_type == 1){
                CommentsWithTrendController *commentsWithTrendController = [[CommentsWithTrendController alloc] init];
                commentsWithTrendController.actionId = attachment.link_id;
                [self.navigationController pushViewController:commentsWithTrendController animated:true];
                return;
            }
            //话题
            if(attachment.link_type == 2){
                
                TopicListContainController *topicListContainController = [[TopicListContainController alloc] init];
                topicListContainController._topicCircleId = attachment.link_id;
                [self.navigationController pushViewController:topicListContainController animated:true];
                return;
            }
            //周末游
            if(attachment.link_type == 3){
                if(attachment.link_id != nil){
                    WeekendTourDetailController *weekendTourDetailController = [[WeekendTourDetailController alloc] init];
                    weekendTourDetailController.weekendId = attachment.link_id;
                    [self.navigationController pushViewController:weekendTourDetailController animated:true];
                }
                if(attachment.link_id == nil){
                    WeekendTourController *weekendTourController = [[WeekendTourController alloc] init];
                    [self.navigationController pushViewController:weekendTourController animated:true];
                }
                return;
            }
        }
        return;
    }
    if(linkURL != nil){
        NTESLiMiWebController *webController = [[NTESLiMiWebController alloc] init];
        webController.url = linkURL;
        [self.navigationController pushViewController:webController animated:true];
        return ;
    }
}

- (BOOL)onTapAvatar:(NIMMessage *)message{
    return false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

//是否需要显示输入框 : 某些场景不需要显示输入框，如使用 3D touch 的场景预览会话界面内容
- (BOOL)shouldShowInputView
{
    return NO;
    BOOL should = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableInputView)]) {
        should = ![self.sessionConfig disableInputView];
    }
    return should;
}
@end
