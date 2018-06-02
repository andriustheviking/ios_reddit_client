//
//  AuthorizationToken.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/1/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation
import UIKit


class AuthorizationToken {
    
    func retrieveToken(withCode code: String)  -> [String:Any]? {
        
        let clientId = oauthSecret.clientId
        let secret = oauthSecret.secret
        let redirectURI = oauthSecret.redirectURI
        let userAgent = oauthSecret.userAgent
        
        
        //get oauth token
        //let url = URL.init(string: "https://www.reddit.com/api/v1/access_token")
        let url = URL.init(string: "http://localhost:8080/print")
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let userPass = "\(clientId):\(secret)"
        guard let base64UserPass: String = (userPass.data(using: .utf8)?.base64EncodedString()) else { return nil }
        
        request.setValue("Basic \(base64UserPass)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let postBody = "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectURI)"
        request.httpBody = postBody.data(using: .utf8)
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error  in
            
            guard error == nil else { return }
            guard let data = data else { return }
            do {

                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    
                }
            } catch let error {
                //is error blocking code?
                print(error.localizedDescription )
                
            }
        })
        task.resume()
        return nil
    }
}
