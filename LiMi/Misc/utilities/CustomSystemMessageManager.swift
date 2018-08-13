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

enum CustomSystemMessageType {
    ///全部消息
    case all
    ///粉丝
    case fans
    ///评论
    case comment
    ///点赞
    case thumbUp
    ///@消息
    case remind
}
let customSystemMessageUnreadCountChanged = Notification.Name.init("customSystemMessageUnreadCountChanged")

class CustomSystemMessageManager: NSObject {
    static let shared = CustomSystemMessageManager.init()
    private let realm = try! Realm()
    
    override init() {
        super.init()
    }
    
    func customSystemMessageUnreadCount(type:CustomSystemMessageType)->Int{
        var filter = ""
        if type == .all{
        }
        if type == .fans{
            filter = "type = 3"
        }
        if type == .comment{
            filter = "type = 1"
        }
        if type == .thumbUp{
            filter = "type = 0"
        }
        if type == .remind{
            filter = "type = 2"
        }
        var models:Results<CustomSystemMessageModel>
        if filter == ""{
            models = self.realm.objects(CustomSystemMessageModel.self)
        }else{
            models = self.realm.objects(CustomSystemMessageModel.self).filter(filter)
        }
        return models.count
    }
    
    func markCustomSystemMessageRead(type:CustomSystemMessageType){
        var filter = ""
        if type == .all{
        }
        if type == .fans{
            filter = "type = 3"
        }
        if type == .comment{
            filter = "type = 1"
        }
        if type == .thumbUp{
            filter = "type = 0"
        }
        if type == .remind{
            filter = "type = 2"
        }
        let tmpUnreadCount = self.customSystemMessageUnreadCount(type: type)
        try! self.realm.write {
            var models:Results<CustomSystemMessageModel>
            if filter == ""{
                models = self.realm.objects(CustomSystemMessageModel.self)
            }else{
                models = self.realm.objects(CustomSystemMessageModel.self).filter(filter)
            }
            self.realm.delete(models)
        }
        if tmpUnreadCount != self.customSystemMessageUnreadCount(type: type){
            NotificationCenter.default.post(name: customSystemMessageUnreadCountChanged, object: nil)
        }
    }
    
    
    ///添加一条系统消息进入本地数据库
    func addCustomSystemMessageWith(nimCustomSystemNotification:NIMCustomSystemNotification){
        // 对 JSON 的回应数据进行反序列化操作
        let jsonData = nimCustomSystemNotification.content!.data(using: String.Encoding.utf8)
        let object = try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
        if let _ = object["msg_id"],let _ = object["type"]{
            if object["msg_id"] == nil || object["type"] == nil{return}
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
