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
