//
//  OAuthViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/24/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit
import WebKit

class OAuthViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    
    //wkwebview from https://developer.apple.com/documentation/webkit/wkwebview
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    
    var oauthState: String? = nil
    
    let duration = "permanent"
    let scope = "account,edit,flair,history,identity,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        oauthState = String.random(length: 20)
        
        let URLString = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(oauth.clientId)&response_type=code&state=\(oauthState!)&redirect_uri=\(oauth.redirectURI)&duration=\(duration)&scope=\(scope)"
        
        let oauthURL = URL(string: URLString)
        let request = URLRequest(url: oauthURL!)
      
        webView.load(request)
        
        print ( oauthState ?? "state nil" )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




