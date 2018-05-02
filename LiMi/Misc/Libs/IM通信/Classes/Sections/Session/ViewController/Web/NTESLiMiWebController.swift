//
//  NTESLiMiWebController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/28.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import WebKit

class NTESLiMiWebController: ViewController {
    var _url:String?
    var wkWebView:WKWebView!
    @objc var url:String{
        get{
            if _url != nil{return _url!}
            return ""
        }
        set{
            _url = newValue
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wkWebView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64))
        self.view.addSubview(self.wkWebView)
        self.wkWebView.uiDelegate = self
        self.wkWebView.navigationDelegate = self
        var request:URLRequest?
        if let _urlStr = self._url{
            if let url = URL.init(string: _urlStr){
                request = URLRequest.init(url: url)
            }
        }
        if nil != request{
            self.wkWebView.load(request!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension NTESLiMiWebController:WKUIDelegate{
    
}

extension NTESLiMiWebController:WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = webView.title ?? "粒米校园"
        Toast.dismiss()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //Toast.showStatusWith(text: nil)
        self.title = "加载中..."
        print(webView.title)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //Toast.showErrorWith(msg: error.localizedDescription)
    }
}
