//
//  SuspensionExpandMenu.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/12.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

///菜单宽度
let suspensionExpandMenuWidth = CGFloat(140)

class SuspensionExpandMenu: UIView {
    var actions = [SuspensionMenuAction]()
    ///菜单容器
    private var menuContainView:UIView!
    ///菜单列表
    private var tableView:UITableView!
    ///三角形
    private var triangleImageView:UIImageView!
    private var suitableActionItemSize = CGSize.zero
    
    convenience init(actions:[SuspensionMenuAction]) {
        self.init(frame: SCREEN_RECT)
        self.actions = actions
        let suitableSize = self.suitableWidthWith(actions: actions)
        self.suitableActionItemSize = suitableSize
        
        self.menuContainView = UIView.init(frame: CGRect.zero)
//        self.menuContainView.backgroundColor = UIColor.white
        self.addSubview(self.menuContainView)
        
        self.tableView = UITableView.init(frame: CGRect.zero)
        self.tableView.separatorStyle = .none
        self.tableView.register(SuspensionMenuItemCell.self, forCellReuseIdentifier: "SuspensionMenuItemCell")
        self.tableView.register(SuspensionMenuItemWithImageCell.self, forCellReuseIdentifier: "SuspensionMenuItemWithImageCell")
        self.tableView.estimatedRowHeight = 1000
        self.tableView.layer.cornerRadius = 5
        self.tableView.clipsToBounds = true
        self.menuContainView.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.triangleImageView = UIImageView.init(frame: CGRect.zero)
        self.menuContainView.addSubview(triangleImageView)

        self.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _touch = touches.first{
            if !_touch.location(in: self).inRect(rect: self.menuContainView.frame){
                self.dissmiss()
            }
        }
    }
    
    //MARK: - misc
    
    //根据传入的actions的title获取合适的菜单单元的size
    func suitableWidthWith(actions:[SuspensionMenuAction]?)->CGSize{
        var longestTitle = ""
        if let _actions = actions{
            for action in _actions{
                if let _title = action.title{
                    if _title.lengthOfBytes(using: String.Encoding.utf8) >= longestTitle.lengthOfBytes(using: String.Encoding.utf8){
                        longestTitle = _title
                    }
                }
            }
        }
        
        let nsLongestTitle = NSString.init(string: longestTitle)
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        let size = nsLongestTitle.boundingRect(with: CGSize.init(width: 1000, height: 100), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        return size
    }
    
    func showAround(view:UIView?){
        if let _view = view{
            ///ContainView
            let menuContainViewHeight = (self.suitableActionItemSize.height+CGFloat(15.0*2))*CGFloat(self.actions.count) + CGFloat(5)
            let menuContainViewWidth = suspensionExpandMenuWidth
            let menuContainViewX = SCREEN_WIDTH-suspensionExpandMenuWidth-5
            var menuContainViewY = CGFloat(0)
            
            let tableViewHeight = (self.suitableActionItemSize.height+CGFloat(15.0*2))*CGFloat(self.actions.count)
            let tableViewWidth = suspensionExpandMenuWidth
            let tableViewX = CGFloat(0)
            var tableViewY = CGFloat(0)
            
            let triangleHeight = CGFloat(5)
            let triangleWidth = CGFloat(5)
            var triangleX = CGFloat(0)
            var triangleY = CGFloat(0)
            
            //校准各视图位置
            let window = UIApplication.shared.keyWindow
            let viewRect = _view.convert(_view.bounds, to: window)
            //判断上下
            triangleX = (viewRect.origin.x + viewRect.size.width*0.5)-menuContainViewX-triangleWidth*0.5
            if (SCREEN_HEIGHT-viewRect.maxY) > menuContainViewHeight{
//            if ( viewRect.origin.y - menuContainViewHeight) < CGFloat(64){
                //下
                menuContainViewY = viewRect.maxY
                tableViewY = CGFloat(5)
                triangleY = CGFloat(0)
                triangleImageView.image = UIImage.init(named: "tc_sjxs")
            }else{
                //上
                menuContainViewY = viewRect.origin.y - menuContainViewHeight
                tableViewY = CGFloat(0)
                triangleY = tableViewHeight
                triangleImageView.image = UIImage.init(named: "tc_sjxx")
            }
            
            self.menuContainView.frame = CGRect.init(x: menuContainViewX, y: menuContainViewY, width: menuContainViewWidth, height: menuContainViewHeight)
            self.tableView.frame = CGRect.init(x: tableViewX, y: tableViewY, width: tableViewWidth, height: tableViewHeight)
            self.triangleImageView.frame = CGRect.init(x: triangleX, y: triangleY, width: triangleWidth, height: triangleHeight)
            window?.addSubview(self)
        }
    }
    
    @objc func dissmiss(){
        self.removeFromSuperview()
    }
}

extension SuspensionExpandMenu:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.actions.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let suspensionMenuAction = self.actions[indexPath.row]
        
        var suspensionMenuItemCell:SuspensionMenuItemCell!
        if suspensionMenuAction.image != nil{
            suspensionMenuItemCell = tableView.dequeueReusableCell(withIdentifier: "SuspensionMenuItemWithImageCell", for: indexPath) as! SuspensionMenuItemCell
        }else{
           suspensionMenuItemCell = tableView.dequeueReusableCell(withIdentifier: "SuspensionMenuItemCell", for: indexPath) as! SuspensionMenuItemCell
        }
        suspensionMenuItemCell.configWith(model: suspensionMenuAction)
        return suspensionMenuItemCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suspensionMenuAction = self.actions[indexPath.row]
        if let _action = suspensionMenuAction.actionBlock{
            _action()
        }
        self.dissmiss()
    }
}







