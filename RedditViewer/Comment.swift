//
//  Comment.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/6/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation

class Comment{
    
    let replyBody: String
    let commentReplies: Array<RedditComments>
    
    init(listing: [String:Any]) {
        
        replyBody = ""
        commentReplies = Array<RedditComments>()
        
        guard let listingData = listing["data"] as? [String:Any] else {return}
        guard let children = listingData["children"] as? Array<[String:Any]> else { return }
        
        //thing is not my term
        for thing in children {
            
            if let commentData = thing["data"] as? [String:Any] {
                
                self.replyBody = commentData["body"] as? String ?? ""
                
                guard let replies = commentData["replies"] as? [String:Any] else { continue }
                guard let repliesData = replies["data"] as? [String:Any] else { continue }
                guard let repliesChildren = repliesData["children"] as? Array<[String:Any]> else {continue}
                
                for reply in repliesChildren {
                    commentReplies.append(reply)
                }
            }
        }
    }
}
