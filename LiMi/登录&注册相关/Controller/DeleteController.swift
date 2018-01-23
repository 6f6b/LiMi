//
//  DeleteController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class DeleteController: ViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var widthConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var heightConstrait: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.widthConstrait.constant = SCREEN_WIDTH
        self.heightConstrait.constant = SCREEN_HEIGHT-20
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
