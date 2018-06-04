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
    func receivedCredentials(code: String? )
}

class OAuthViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView!
    var oauthState: String? = nil   //set in segue
    
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
        
        if let state = oauthState {
    
            let oauthURL = APICalls.authRequestUrl(withState: state)
            let request = URLRequest(url: oauthURL)
            webView.load(request)
        }
    }
    
    
    var credentialDelegate : OAuthCredentialDelegate?
    
    //MARK: - Webview Navigation Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else { return }
        
        //if redirect from oauth, pass credentials to delegate and dismiss
        if let host = url.host, "https://"+host == Credentials.redirectURI {
            
            //cancel redirection
            decisionHandler(.cancel)
            
            if let code = url.valueOf(queryParameter: "code"), let delegate = self.credentialDelegate {
                delegate.receivedCredentials( code: code )
            }
            
            _ = navigationController?.popViewController(animated: true)
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





