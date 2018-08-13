//
//  UIKitExtension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    static func imageWithUIView(view: UIView)->UIImage{
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        let currentContext = UIGraphicsGetCurrentContext()
        view.layer.render(in: currentContext!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func cutCircleImage(view: UIView)->UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        let currentContext = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        currentContext?.addEllipse(in: rect)
        currentContext?.clip()
        view.draw(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UILabel {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension String{
    ///获取字符串在限定宽度内的size
    func sizeWith(limitWidth:CGFloat,font:CGFloat)->CGSize{
        let nsStr = NSString.init(string: self)
        let rect = nsStr.boundingRect(with: CGSize.init(width: 10000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: font)], context: nil)
        var lines = rect.width / limitWidth
        let remainder = lines.truncatingRemainder(dividingBy: 1)
        if remainder != 0{
            lines = CGFloat(Int(lines) + 1)
        }
        let width = rect.width < limitWidth ? rect.width : limitWidth
        return CGSize.init(width: width, height: rect.height*lines)
    }
}

extension UIButton{
    @objc func sizeToFitTitleLeftImageWith(distance:CGFloat){
        let selectStatus = self.isSelected
        self.isSelected = true
        var imageWidth = CGFloat(0)
        var titleWidth = CGFloat(0)
        if let titleLabel  = self.titleLabel,let imageView = self.imageView{
            self.sizeToFit()
            imageWidth = imageView.frame.size.width
            titleWidth = titleLabel.frame.size.width
            self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -imageWidth, bottom: 0, right: imageWidth)
            self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: titleWidth, bottom: 0, right: -titleWidth)
        }
        self.isSelected = false
        if let titleLabel  = self.titleLabel,let imageView = self.imageView{
            if (imageView.frame.size.width + titleLabel.frame.size.width) > (imageWidth+titleWidth){
                imageWidth = imageView.frame.size.width
                titleWidth = titleLabel.frame.size.width
                
                self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -imageWidth, bottom: 0, right: imageWidth)
                self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: titleWidth, bottom: 0, right: -titleWidth)
                self.sizeToFit()
            }
        }
        var frame = self.frame
        frame.size.width = imageWidth+titleWidth
        self.frame = frame
        self.isSelected = selectStatus
    }
    
    @objc func sizeToFitTitleBelowImageWith(distance:CGFloat){
        self.sizeToFit()
        self.imageView?.sizeToFit()
        self.titleLabel?.sizeToFit()
        if let imageFrame = self.imageView?.frame,let titleFrame = self.titleLabel?.frame{
            let height = imageFrame.size.height+distance+titleFrame.size.height
            let width = imageFrame.size.width > titleFrame.size.width ? imageFrame.size.width : titleFrame.size.width
            let _imageFrame = imageFrame;

            let _titleFrame = titleFrame;

            
            var _frame = self.frame;
            _frame.size.width = width;
            _frame.size.height = height;
            self.frame = _frame;
            
            self.titleEdgeInsets = UIEdgeInsets.init(top: _imageFrame.size.height+distance/2, left: -imageFrame.size.width, bottom: 0, right: 0);
            self.imageEdgeInsets = UIEdgeInsets.init(top: -_titleFrame.size.height-distance/2, left: 0, bottom: 0, right: -_titleFrame.size.width);
        }
    }
    func setContentInCenter(){
        var imageViewSize:CGSize?
        var titleSize:CGSize?
        var btnSize: CGSize?

        var imageViewEdge : UIEdgeInsets?
        var titleEdge : UIEdgeInsets?
        var heightSpace = self.frame.size.height
        
        imageViewSize = self.imageView?.bounds.size
        titleSize = self.titleLabel?.bounds.size
        btnSize = self.bounds.size
        
        imageViewEdge = UIEdgeInsets.init(top: CGFloat(heightSpace), left: 0.0, bottom: (btnSize?.height)!-(imageViewSize?.height)!, right: (-titleSize!.width))
        self.imageEdgeInsets = imageViewEdge!
        titleEdge = UIEdgeInsets.init(top: imageViewSize!.height + CGFloat(heightSpace), left: -imageViewSize!.width, bottom: 0.0, right: 0.0)
        self.titleEdgeInsets = titleEdge!
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}


