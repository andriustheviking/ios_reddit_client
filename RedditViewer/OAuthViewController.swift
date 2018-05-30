//
//  OAuthViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/24/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit
import WebKit

//delegate to send oauth credentials back to calling segue
protocol OAuthCredentialDelegate {
    func receivedCredentials(state: String?, code: String? )
}

class OAuthViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {


    var webView: WKWebView!
    var oauthState: String? = nil
    
    override func loadView() {
        super.loadView()
        
        //MARK: - Webview Configuration
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //load reddit oauth2.0 authorization page
        oauthState = String.random(length: 20)
        let URLString = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(oauth.clientId)&response_type=code&state=\(oauthState!)&redirect_uri=\(oauth.redirectURI)&duration=\(oauth.duration)&scope=\(oauth.scope)"
        let oauthURL = URL(string: URLString)
        let request = URLRequest(url: oauthURL!)
        webView.load(request)
    }
    
    
    var credentialDelegate : OAuthCredentialDelegate?
    
    //MARK: - Webview Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else { return }
        
        //if oauth redirect, pass credentials to delegate and dismiss
        if let host = url.host, host == "andriuskelly.com" {
            
            decisionHandler(.cancel)
            
            if let delegate = credentialDelegate {
                delegate.receivedCredentials(state: url.valueOf(queryParameter: "state"), code: url.valueOf(queryParameter: "code") )
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        decisionHandler(.allow)
    }
}

// MARK: URL Query Parameter Extension
// extension from: https://stackoverflow.com/questions/41421686/get-the-value-of-url-parameters?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
extension URL {
    func valueOf(queryParameter: String) -> String? {
        guard  let url = URLComponents.init(string: self.absoluteString ) else { return nil }
        
        return url.queryItems?.first(where: { $0.name == queryParameter})?.value
    }
}




