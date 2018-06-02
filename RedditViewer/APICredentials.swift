//
//  RedditAPICredentials.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/1/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation

struct Credentials {
    static let clientId = oauthSecret.clientId
    static let secret = oauthSecret.secret
    static let redirectURI = oauthSecret.redirectURI
    static let scope = oauthSecret.scope
    static let duration = oauthSecret.duration
    static let userAgent = oauthSecret.userAgent
}
