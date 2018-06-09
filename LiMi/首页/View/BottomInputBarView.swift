//
//  BottomInputBarView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/8.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol BottomInputBarViewDelegate {
    func sentContentButtonClicked(button:UIButton,textFeild:UITextField?)
}
class BottomInputBarView: UIView {
    var keyboard:STEmojiKeyboard?
    var textFeild:UITextField!
    var switchInputTypeButton:UIButton!
    var sentContentButton:UIButton!
    var seperateLine:UIView!
    
    var delegate:BottomInputBarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        let width = frame.size.width
        let height = frame.size.height
        self.sentContentButton = UIButton.init(frame: CGRect.init(x: width-43, y: 0, width: 28, height: 28))
        self.sentContentButton.setImage(UIImage.init(named: "pl_send2"), for: .normal)
        self.sentContentButton.addTarget(self, action: #selector(sentContentButtonClicked(button:)), for: .touchUpInside)
        var sentContentButtonCenter = self.sentContentButton.center
        sentContentButtonCenter.y = height * 0.5
        self.sentContentButton.center = sentContentButtonCenter
        self.addSubview(self.sentContentButton)
        
        self.switchInputTypeButton = UIButton.init(frame: CGRect.init(x: self.sentContentButton.frame.origin.x-15-28, y: 0, width: 28, height: 28))
        self.switchInputTypeButton.setImage(UIImage.init(named: "pl_bq2"), for: .normal)
        self.switchInputTypeButton.addTarget(self, action: #selector(switchInputTypeButtonClicked(button:)), for: .touchUpInside)
        var switchInputTypeButtonCenter = self.switchInputTypeButton.center
        switchInputTypeButtonCenter.y = height * 0.5
        self.switchInputTypeButton.center = switchInputTypeButtonCenter
        self.addSubview(self.switchInputTypeButton)
        
        self.textFeild = UITextField.init(frame: CGRect.init(x: 15, y: 0, width: self.switchInputTypeButton.frame.origin.x, height: height))
        self.textFeild.font = UIFont.systemFont(ofSize: 15)
        self.textFeild.textColor = UIColor.white
        self.textFeild.attributedPlaceholder = NSAttributedString.init(string: "说点什么..", attributes: [NSAttributedStringKey.foregroundColor:RGBA(r: 255, g: 255, b: 255, a: 1)])
        self.textFeild.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
        self.addSubview(self.textFeild)
        
        self.seperateLine = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: 1))
        self.seperateLine.backgroundColor = UIColor.white
        self.addSubview(self.seperateLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldValueChanged(textField:UITextField!){
        self.sentContentButton.isEnabled = !IsEmpty(textField: textField)
    }
    
    @objc func sentContentButtonClicked(button:UIButton){
        self.delegate?.sentContentButtonClicked(button: button, textFeild: self.textFeild)
    }
    
    @objc func switchInputTypeButtonClicked(button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected{
            if self.keyboard == nil{
                self.keyboard = STEmojiKeyboard()
            }
            self.keyboard?.textView = self.textFeild
        }else{
            self.textFeild.inputView = nil
        }
        self.textFeild.reloadInputViews()
        self.textFeild.becomeFirstResponder()
    }
    
}
