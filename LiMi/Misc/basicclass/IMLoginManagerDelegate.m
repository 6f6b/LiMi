//
//  IMLoginManagerDelegate.m
//  LiMi
//
//  Created by dev.liufeng on 2018/7/30.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "IMLoginManagerDelegate.h"
#import "NTESSessionUtil.h"
#import "LiMi-Swift.h"
@interface IMLoginManagerDelegate()<NIMLoginManagerDelegate>
@end
@implementation IMLoginManagerDelegate
#pragma mark: - NIMLoginManagerDelegate
- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType{
    
}

- (void)onAutoLoginFailed:(NSError *)error{
    [self showAutoLoginErrorAlert:error];
}

- (void)onLogin:(NIMLoginStep)step{
//    /**
//     *  连接服务器
//     */
//    NIMLoginStepLinking = 1,
//    /**
//     *  连接服务器成功
//     */
//    NIMLoginStepLinkOK,
//    /**
//     *  连接服务器失败
//     */
//    NIMLoginStepLinkFailed,
//    /**
//     *  登录
//     */
//    NIMLoginStepLogining,
//    /**
//     *  登录成功
//     */
//    NIMLoginStepLoginOK,
//    /**
//     *  登录失败
//     */
//    NIMLoginStepLoginFailed,
//    /**
//     *  开始同步
//     */
//    NIMLoginStepSyncing,
//    /**
//     *  同步完成
//     */
//    NIMLoginStepSyncOK,
//    /**
//     *  连接断开
//     */
//    NIMLoginStepLoseConnection,
//    /**
//     *  网络切换
//     *  @discussion 这个并不是登录步骤的一种,但是UI有可能需要通过这个状态进行UI展现
//     */
//    NIMLoginStepNetChanged,
    NSString *info = @"";
    switch (step) {
        case NIMLoginStepLinking:
            info = @"正在连接服务器";
            break;
        case NIMLoginStepLinkOK:
            info = @"连接服务器成功";
            break;
        case NIMLoginStepLinkFailed:
            info = @"连接服务器失败";
            break;
        case NIMLoginStepLogining:
            info = @"正在登录";
            break;
        case NIMLoginStepLoginOK:
            info = @"登录成功";
            [NSNotificationCenter.defaultCenter postNotificationName:@"LOGIN_IM_SUCCESS_NOTIFICATION" object:nil];
            break;
        case NIMLoginStepLoginFailed:
            info = @"登录失败";
            break;
        case NIMLoginStepSyncing:
            info = @"开始同步";
            break;
        case NIMLoginStepSyncOK:
            info = @"同步完成";
            break;
        case NIMLoginStepLoseConnection:
            info = @"连接断开";
            break;
        case NIMLoginStepNetChanged:
            info = @"网络切换";
            break;
        default:
            break;
    }
    NSLog(@"%@",info);
}

- (void)showAutoLoginErrorAlert:(NSError *)error{
    NSString *message = [NTESSessionUtil formatAutoLoginMessage:error];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"自动登录失败" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionRetry = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[AppManager shared] loginIM];
    }];
    UIAlertAction *actionLogOut = [UIAlertAction actionWithTitle:@"注销" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"LOGOUT_NOTIFICATION" object:nil];
    }];
    [alertController addAction:actionRetry];
    [alertController addAction:actionLogOut];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:true completion:nil];
}


//func onKick(_ code: NIMKickReason, clientType: NIMLoginClientType) {
//    var reason = "你被踢下线"
//    switch code {
//    case NIMKickReason.byClient:
//        let clientName = NTESClientUtil.clientName(clientType)
//        if let _clientName = clientName{
//            if _clientName.count > 0{
//                reason = "你的账号在其他\(_clientName)端登录，请注意账号信息安全"
//            }
//        }
//        break
//    case NIMKickReason.byClientManually:
//        let clientName = NTESClientUtil.clientName(clientType)
//        if let _clientName = clientName{
//            if _clientName.count > 0{
//                reason = "你的账号在其他\(_clientName)端登录，请注意账号信息安全"
//            }
//        }
//    case NIMKickReason.byServer:
//        reason = "你被服务器踢下线"
//        break
//    default:
//        break
//    }
//    NIMSDK.shared().loginManager.logout { (error) in
//        let alterController = UIAlertController.init(title: "下线通知", message: reason, preferredStyle: .alert)
//        let acttionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
//            NotificationCenter.default.post(name: NTESNotificationLogout, object: nil, userInfo: nil)
//        })
//        alterController.addAction(acttionOK)
//        UIApplication.shared.keyWindow?.rootViewController?.present(alterController, animated: true, completion: nil)
//    }
//
//    func onAutoLoginFailed(error:Error){
//        //只有连接发生严重错误才会走这个回调，在这个回调里应该登出，返回界面等待用户手动重新登录。
//        self.showAutoLoginErrorAlert(error: error)
//    }
//
//    func onLogin(step:NIMLoginStep){
//        print("####################")
//        print(step)
//        if step == .loginOK{
//            NotificationCenter.default.post(name: LOGIN_IM_SUCCESS_NOTIFICATION, object: nil)
//        }
//        print("*******************************")
//    }
//
//}
@end
