//
//  APICalls.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/3/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation

//closure design: https://stackoverflow.com/questions/43048120/swift-return-data-from-urlsession?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
class APICalls {
    
    static func authRequestUrl(withState state: String) -> URL
    {
        let urlString = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(Credentials.clientId)&response_type=code&state=\(state)&redirect_uri=\(Credentials.redirectURI)&duration=\(Credentials.duration)&scope=\(Credentials.scope)&secret=\(Credentials.secret)"
        
        return URL(string: urlString)!
    }
    
    
    static func redditRequest(endpoint: String, token: String?, method:String="GET", body:String="") -> URLRequest {
        
        let url = URL.init(string: "https://www.reddit.com/" + endpoint)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = method
        
        if let token = token {
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(Credentials.userAgent, forHTTPHeaderField: "User-Agent")
        
        request.httpBody = body.data(using: .utf8)
        
        return request
    }
    
    
    //builds the URL POST request for the OAuth Token
    static func tokenRequest(code: String) -> URLRequest? {
        
        let url = URL.init(string: "https://www.reddit.com/api/v1/access_token")
        
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

    
    //retrieves json [String:Any] via POST request and passes it via completion block
    static func getJSON(via request: URLRequest?, completionBlock: @escaping ([String : Any]) -> Void) {
        
        if let request = request {
        
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error  in
                
                guard error == nil else { return }
                
                guard let data = data else { return }
                
                do {
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized {
                        print("calling completion block:")
                        completionBlock(json)
                    }
                    else {
                        print ("could not unwrap json")
                    }
                    
                } catch let error {
                    //is error blocking code?
                    print(error.localizedDescription)
                }
            })
            
            task.resume()
        }
    }
}
