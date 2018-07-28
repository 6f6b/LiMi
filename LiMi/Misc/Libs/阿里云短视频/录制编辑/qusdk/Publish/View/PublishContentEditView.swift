//
//  PublishContentEditView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class PublishContentEditView: AliyunPublishContentEditView {
    var remindedModels = [UserInfoModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textView.customTextViewDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addRemindedModel(model:UserInfoModel){
        if let nsName = model.nickname ?? model.id_code{
        }
        
        remindedModels.append(model)
        
    }
    
    func refreshTextStatus(){
        let nsAttText = NSMutableAttributedString.init(string: self.textView.text)
        let nsText = NSString.init(string: self.textView.text)
        
        for i in 0..<remindedModels.count{
            let model = remindedModels[i]
            if let keyWord = model.nickname ?? model.id_code{
                let range = nsText.range(of: "@\(keyWord)")
                nsAttText.addAttributes([NSAttributedStringKey.foregroundColor:RGBA(r: 241, g: 30, b: 101, a: 1)], range: range)
            }
        }
        self.textView.attributedText = nsAttText
    }
    
    @objc func customTextViewClickedDelete(_ customTextView: CustomTextView!) {
        
    }
}

extension PublishContentEditView: CustomTextViewDelegate{
//    func customTextViewClickedDelete(_ customTextView: CustomTextView!) {
//        let nsTxt = NSString.init(string: customTextView.text)
//        customTextView.manualDelete()
//        //#pragma mark - CustomTextViewDelegate
//        //- (void)customTextViewClickedDelete:(CustomTextView *)customTextView{
//        //    NSRange range = [customTextView.text rangeOfString:@""];
//        //    NSLocationInRange(<#NSUInteger loc#>, <#NSRange range#>)
//        //    //判断是否需要选中整个@内容dsf
//        //    [customTextView manualDelete];
//        //}
//    }
}
