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
    func receivedCredentials(token: String? )
}

class OAuthViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {


    let clientId = oauthSecret.clientId
    let secret = oauthSecret.secret
    let redirectURI = oauthSecret.redirectURI
    let scope = oauthSecret.scope
    let duration = oauthSecret.duration
    let userAgent = oauthSecret.userAgent
    
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
        
        var URLString = "https://www.reddit.com/api/v1/authorize.compact?"
        URLString += "client_id=\(clientId)"
        URLString += "&response_type=code"
        URLString += "&state=\(oauthState!)"
        URLString += "&redirect_uri=\(redirectURI)"
        URLString += "&duration=\(duration)"
        URLString += "&scope=\(scope)"
        URLString += "&secret=\(secret)"
        
        print ("initial request url: " + URLString)
        
        let oauthURL = URL(string: URLString)
        let request = URLRequest(url: oauthURL!)
        webView.load(request)
    }
    
    
    var credentialDelegate : OAuthCredentialDelegate?
    
    //MARK: - Webview Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else { return }
        
        //if oauth redirect, pass credentials to delegate and dismiss

        if let host = url.host, "https://"+host == redirectURI {
            
            //cancel redirection
            decisionHandler(.cancel)
            print("Redirect to " + redirectURI + " cancelled")
            
            if let code = url.valueOf(queryParameter: "code") {
                
                print ("State: " + oauthState!)
                print ("Code: " + code)
                
                //get oauth token
//                let url = URL.init(string: "https://www.reddit.com/api/v1/access_token")
                let url = URL.init(string: "http://localhost:8080/print")
                let session = URLSession.shared
                var request = URLRequest(url: url!)
                
                request.httpMethod = "POST"
                
//                request.setValue(clientId, forHTTPHeaderField: "user")
//                request.setValue(secret, forHTTPHeaderField: "password")
                let userPass = "\(clientId):\(secret)"
                guard let base64UserPass: String = (userPass.data(using: .utf8)?.base64EncodedString()) else { return }
                
                request.setValue("Basic \(base64UserPass)", forHTTPHeaderField: "Authorization")
                
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let postBody = "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectURI)"
                request.httpBody = postBody.data(using: .utf8)

                
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error  in
                    
                    guard error == nil else { return }
                    guard let data = data else { return }
                    do {
                        if let delegate = self.credentialDelegate {
                            guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else { return }
                            guard let token = json["access_token"] as? String else { return }
                            
                            delegate.receivedCredentials( token: token )
                        }
                        //TODO: fix reference to self
                        self.dismiss(animated: true, completion: nil)
                    } catch let error {
                        //is error blocking code?
                        print(error.localizedDescription )
                    }
                })
                
                task.resume()
   
            }
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


//http request from
//https://stackoverflow.com/questions/24016142/how-to-make-an-http-request-in-swift?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa


