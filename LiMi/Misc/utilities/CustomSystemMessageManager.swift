//
//  SystemMessageManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/8.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

//public protocol CustomSystemMessageManager {
//    ///自定义系统消息未读数改变了
//    func customSystemMessageAllUnreadCountChanged()
//}
let customSystemMessageUnreadCountChanged = Notification.Name.init("customSystemMessageUnreadCountChanged")

class CustomSystemMessageManager: NSObject {
    static let shared = CustomSystemMessageManager.init()
    private let realm = try! Realm()
    
    override init() {
        super.init()
    }
    
    ///全部未读
    func allCustomSystemMessageUnreadCount()->Int{
        let models = self.realm.objects(CustomSystemMessageModel.self)
        return models.count
    }
    
    ///点赞消息未读数
    func allThumbUpMessageUnreadCount()->Int{
        let models = self.realm.objects(CustomSystemMessageModel.self).filter("type = 0")
        return models.count
    }
    
    ///评论消息未读数
    func allCommentMessageUnreadCount()->Int{
        let models = self.realm.objects(CustomSystemMessageModel.self).filter("type = 1")
        return models.count
    }
    
    ///标记全部系统消息已读
    func markAllCustomSystemMessageRead(){
        let tmpAllUnreadCount = self.allCustomSystemMessageUnreadCount()
        try! self.realm.write {
            self.realm.deleteAll()
        }
        if tmpAllUnreadCount != self.allCustomSystemMessageUnreadCount(){
            NotificationCenter.default.post(name: customSystemMessageUnreadCountChanged, object: nil)
        }
    }
    
    ///标记所有点赞消息已读
    func markAllThumbUpMessageRead(){
        let tmpAllThumbUpUnreadCount = self.allThumbUpMessageUnreadCount()
        try! self.realm.write {
            let models = self.realm.objects(CustomSystemMessageModel.self).filter("type = 0")
            self.realm.delete(models)
        }
        if tmpAllThumbUpUnreadCount != self.allThumbUpMessageUnreadCount(){
            NotificationCenter.default.post(name: customSystemMessageUnreadCountChanged, object: nil)
        }
    }
    
    ///标记所有评论消息已读
    func markAllCommentMessageRead(){
        let tmpAllCommentUnreadCount = self.allCommentMessageUnreadCount()
        try! self.realm.write {
            let models = self.realm.objects(CustomSystemMessageModel.self).filter("type = 1")
            self.realm.delete(models)
        }
        if tmpAllCommentUnreadCount != self.allThumbUpMessageUnreadCount(){
            NotificationCenter.default.post(name: customSystemMessageUnreadCountChanged, object: nil)
        }
    }
    
    ///添加一条系统消息进入本地数据库
    func addCustomSystemMessageWith(nimCustomSystemNotification:NIMCustomSystemNotification){
        // 对 JSON 的回应数据进行反序列化操作
        let jsonData = nimCustomSystemNotification.content!.data(using: String.Encoding.utf8)
        let object = try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
        if let _ = object["msg_id"],let _ = object["type"]{
            try! self.realm.write {
                let _ = self.realm.create(CustomSystemMessageModel.self, value: object, update: true)
            }
            NotificationCenter.default.post(name: customSystemMessageUnreadCountChanged, object: nil)
        }
    }
}

///自定义系统消息模型
class CustomSystemMessageModel:Object{
    //id
    @objc dynamic var msg_id:String = ""
    //type
    @objc dynamic var type:Int = 0
    
    override static func primaryKey() -> String? {
        return "msg_id"
    }

}
