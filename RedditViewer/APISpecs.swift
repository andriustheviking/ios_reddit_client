//
//  APISpecs.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/1/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation


class RedditSpecs {
    
    static func authRequestUrl(withState state: String) -> URL
    {
        let urlString = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(Credentials.clientId)&response_type=code&state=\(state)&redirect_uri=\(Credentials.redirectURI)&duration=\(Credentials.duration)&scope=\(Credentials.scope)&secret=\(Credentials.secret)"
        
        return URL(string: urlString)!
    }
    
    
    //builds the URL POST request for the OAuth Token
    static func authTokenRequest(forCode code: String) -> URLRequest? {
        
        let url = URL.init(string: "https://www.reddit.com/api/v1/access_token")
//        let url = URL.init(string: "http://localhost:8080/print")
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let userPass = "\(Credentials.clientId):\(Credentials.secret)"
        guard let base64UserPass: String = (userPass.data(using: .utf8)?.base64EncodedString()) else { return nil }
        
        request.setValue("Basic \(base64UserPass)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(Credentials.userAgent, forHTTPHeaderField: "User-Agent")
        
        let postBody = "grant_type=authorization_code&code=\(code)&redirect_uri=\(Credentials.redirectURI)"
        request.httpBody = postBody.data(using: .utf8)

        return request
        
    }
}
