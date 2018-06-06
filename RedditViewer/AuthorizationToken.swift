//
//  AuthorizationToken.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/1/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation
import UIKit




class OAuthToken {
    var token_type: String
    var refresh_token: String
    var scope: String
    var expires_in: Date
    var access_token: String
    
    init?(json: [String: Any]) {
        
        guard let token =   json["token_type"]  as? String      else { return nil }
        guard let refresh = json["refresh_token"] as? String    else { return nil }
        guard let scope =   json["scope"]  as? String           else { return nil }
        guard let access =  json["access_token"] as? String     else { return nil }
        guard let seconds = json["expires_in"] as? Double       else { return nil }

        expires_in = Date.init(timeIntervalSinceNow: seconds )
        token_type = token
        refresh_token = refresh
        self.scope = scope
        access_token = access
    }
    
    init?(account: Account){
        
        guard let token = account.token else { return nil }
        guard let expires = account.expires else { return nil }
        guard let refresh = account.refresh_token else { return nil }
        token_type = "bearer"
        
        scope = Credentials.scope
        expires_in = expires as Date
        access_token = token
        refresh_token = refresh
    }
}

