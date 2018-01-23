//
//  PayPasswordInputView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PayPasswordInputView: UIView {
    @IBOutlet weak var topCoverView: UIView!
    @IBOutlet weak var payInfoContainView: UIView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var passwordContainView: UIView!
    @IBOutlet var pwds: [UILabel]!
    @IBOutlet weak var numPadBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContainView: UIView!
    var amountValue:Double = 0.0
    
    var finishedInputPasswordBlock:(()->Void)?
    var nums = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.payInfoContainView.layer.cornerRadius = 20
        self.payInfoContainView.clipsToBounds = true
    
        self.passwordContainView.layer.borderWidth = 1
        self.passwordContainView.layer.borderColor = RGBA(r: 51, g: 51, b: 51, a: 1).cgColor
        
        self.numPadBottomConstraint.constant = -GET_DISTANCE(ratio: 439/750.0)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.amount.text = "¥" + amountValue.decimalValue()
        self.refreshPwdWith(nums: self.nums)
        UIView.animate(withDuration: 1) {
            self.numPadBottomConstraint.constant = 0
            self.topCoverView.layoutIfNeeded()
            self.bottomContainView.layoutIfNeeded()
        }
    }
    
    //MARK: - misc
    @IBAction func dealTapNumPad(_ sender: Any) {
        if nums.count >= 6{return}
        let numBtn = sender as! UIButton
        if numBtn.tag == 100{
            self.nums.append("0")
        }
        if numBtn.tag == 101{
            self.nums.append("1")
        }
        if numBtn.tag == 102{
            self.nums.append("2")
        }
        if numBtn.tag == 103{
            self.nums.append("3")
        }
        if numBtn.tag == 104{
            self.nums.append("4")
        }
        if numBtn.tag == 105{
            self.nums.append("5")
        }
        if numBtn.tag == 106{
            self.nums.append("6")
        }
        if numBtn.tag == 107{
            self.nums.append("7")
        }
        if numBtn.tag == 108{
            self.nums.append("8")
        }
        if numBtn.tag == 109{
            self.nums.append("9")
        }
        self.refreshPwdWith(nums: self.nums)
        if nums.count >= 6{
            if let _finishedInputPasswordBlock = finishedInputPasswordBlock{
                _finishedInputPasswordBlock()
            }
        }
    }
    
    @IBAction func dealClose(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func dealDelete(_ sender: Any) {
        if nums.count <= 0{return}
        self.nums.removeLast()
        self.refreshPwdWith(nums: self.nums)
    }
    
    func refreshPwdWith(nums:[String]){
        for pwd in self.pwds{
            pwd.text = nil
        }
        let numsCount = nums.count
        for i in 0..<numsCount{
            pwds[i].text = nums[i]
        }
    }
}
