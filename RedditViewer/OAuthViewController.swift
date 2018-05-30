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
        webView.navigationDelegate = self
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
        
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else { return }
            
        if let host = url.host, host == "andriuskelly.com" {
            
            print( url.valueOf(queryParameter: "state") ?? "no state" )
            print ( oauthState ?? "state nil" )
            print ( url.valueOf(queryParameter: "code") ?? "no code")
            
            decisionHandler(.cancel)
            
        }
        
        decisionHandler(.allow)
    }
}

// extension from: https://stackoverflow.com/questions/41421686/get-the-value-of-url-parameters?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
extension URL {
    func valueOf(queryParameter: String) -> String? {
        guard  let url = URLComponents.init(string: self.absoluteString ) else { return nil }
        
        return url.queryItems?.first(where: { $0.name == queryParameter})?.value
    }
}




