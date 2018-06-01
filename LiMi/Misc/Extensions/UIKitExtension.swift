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
    @objc func sizeToFitTitleBelowImageWith(distance:CGFloat){
        self.sizeToFit()
        self.imageView?.sizeToFit()
        self.titleLabel?.sizeToFit()
        if let imageFrame = self.imageView?.frame,let titleFrame = self.titleLabel?.frame{
            let height = imageFrame.size.height+distance+titleFrame.size.height
            let width = imageFrame.size.width > titleFrame.size.width ? imageFrame.size.width : titleFrame.size.width
            var _imageFrame = imageFrame;
//            _imageFrame.origin.x = width*0.5-imageFrame.size.width*0.5;
//            _imageFrame.origin.y = 0;
//            self.imageView?.frame = _imageFrame;
            var _titleFrame = titleFrame;
//            _titleFrame.origin.x = 0;
//            _titleFrame.origin.y = height-titleFrame.size.height;
//            self.titleLabel?.frame = _titleFrame;
            
            var _frame = self.frame;
            _frame.size.width = width;
            _frame.size.height = height;
            self.frame = _frame;
            
            self.titleEdgeInsets = UIEdgeInsets.init(top: _imageFrame.size.height+distance/2, left: -imageFrame.size.width, bottom: 0, right: 0);
            self.imageEdgeInsets = UIEdgeInsets.init(top: -_titleFrame.size.height-distance/2, left: 0, bottom: 0, right: -_titleFrame.size.width);
//            btnLeft.titleEdgeInsets = UIEdgeInsets(top: btnLeft.imageView!.frame.size.height, left: -btnLeft.imageView!.frame.size.width, bottom: 0, right: 0)
//
//            //设置图片偏移：向上偏移文字高度＋向右偏移文字宽度 （偏移量是根据［文字］大小来的，这点是关键）
//            btnLeft.imageEdgeInsets = UIEdgeInsets(top: -btnLeft.titleLabel!.bounds.size.height, left: 0, bottom: 0, right: -btnLeft.titleLabel!.bounds.size.width)
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


