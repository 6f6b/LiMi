//
//  BufferView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/14.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class BufferView: UIView {
    private var animationView:UIView!
    var isAllowedToAnimation = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 0)
        
        self.animationView = UIView.init(frame: CGRect.init(x: frame.size.width * 0.5, y: 0, width: 0, height: frame.size.height))
        self.animationView.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 1)
        self.addSubview(self.animationView)
        self.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("缓冲条销毁")
        self.layer.removeAllAnimations()
    }
    
    func startAnimation(){
        isAllowedToAnimation = true
        self.isHidden = false
        self.animationView.layer.removeAllAnimations()
        self.animationView.frame = CGRect.init(x: frame.size.width * 0.5, y: 0, width: 0, height: frame.size.height)
        self.animationView.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 1)
        self.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 0)
        self.animation()
    }
    
    private func animation(){
        if !isAllowedToAnimation{return}
        UIView.animate(withDuration: 0.5, animations: {[unowned self] in
            self.animationView.frame = self.bounds
            self.animationView.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 0.2)
            self.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 0.3)

        }) {[unowned self] (_) in
            self.animationCompleted()
        }

    }
    
    private func animationCompleted(){
        self.animationView.frame = CGRect.init(x: frame.size.width * 0.5, y: 0, width: 0, height: frame.size.height)
        self.animationView.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 1)
        self.backgroundColor = RGBA(r: 255, g: 255, b: 255, a: 0)
        self.animation()
    }
    
    func stopAnimation(){
        isAllowedToAnimation = false
        self.isHidden = true
        self.animationView.layer.removeAllAnimations()
    }

}
