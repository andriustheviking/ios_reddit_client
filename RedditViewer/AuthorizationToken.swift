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
}

