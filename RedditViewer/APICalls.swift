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
    
    

    
    
    //MARK: redditRequest()
    //makes a restful request to reddit's api.
    //host is automatically determined by token presence
    static func redditRequest(endpoint: String, token: String?, method:String="GET", body:String="", contentType:String="application/x-www-form-urlencoded") -> URLRequest {
        
        let host: String
        
        if let _  = token {
            host = "https://oauth.reddit.com"
        } else {
            host = "https://www.reddit.com"
        }
        print(host + endpoint)
        
        let url = URL.init(string: host + endpoint)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = method
        
        if let token = token {
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(Credentials.userAgent, forHTTPHeaderField: "User-Agent")
        
        request.httpBody = body.data(using: .utf8)
        
        return request
    }

    
    //MARK: getJSON()
    //retrieves json [String:Any] via POST request and passes it via completion block
    static func getJSON(via request: URLRequest?, completionBlock: @escaping (Any) -> Void) {
        
        if let request = request {
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error  in
                
                guard error == nil else { return }
                
                guard let data = data else { return }
                
                
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        completionBlock(jsonObject)
                    
                } catch let error {
                    //is error blocking code?
                    print(error.localizedDescription)
                }
            })
            
            task.resume()
        }
    }
}
