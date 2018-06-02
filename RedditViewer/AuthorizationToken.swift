//
//  AuthorizationToken.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/1/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation
import UIKit


//closure design: https://stackoverflow.com/questions/43048120/swift-return-data-from-urlsession?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

struct OAuthToken {
    var token_type: String
    var refresh_token: String
    var scope: String
    var access_token: String
    var expires_in: Int
    
    init?(json: [String: Any]) {
        
        guard let token =   json["token_type"]  as? String      else { return nil }
        guard let refresh = json["refresh_token"] as? String    else { return nil }
        guard let scope =   json["scope"]  as? String           else { return nil }
        guard let access =  json["access_token"] as? String     else { return nil }
        guard let expires = json["expires_in"] as? Int          else { return nil }
        
        token_type = token
        refresh_token = refresh
        self.scope = scope
        access_token = access
        expires_in = expires
    }
}

class AuthorizationToken {

    //retrieves json [String:Any] via POST request and passes it via completion block
    static func retrieveToken(withCode code: String, completionBlock: @escaping ([String : Any]) -> Void) {
        
        let session = URLSession.shared
        guard let request = RedditSpecs.authTokenRequest(forCode: code) else {return}

        
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
