//
//  UtilityExtensions.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/4/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation



extension String {
    //MARK - Random String Extension
    //random string generator: stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}



extension URL {
    // MARK: URL Query Parameter Extension
    // extension from: https://stackoverflow.com/questions/41421686/get-the-value-of-url-parameters?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    func valueOf(queryParameter: String) -> String? {
        guard  let url = URLComponents.init(string: self.absoluteString ) else { return nil }
        
        return url.queryItems?.first(where: { $0.name == queryParameter})?.value
    }
}
