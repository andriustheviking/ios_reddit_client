//
//  Comment.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/6/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation

class RedditComment{
    
    var replyBody: String
    var commentReplies: Array<RedditComment>
    
    init(listing: [String:Any]) {
        
        replyBody = ""
        commentReplies = Array<RedditComment>()
        
        guard let listingData = listing["data"] as? [String:Any] else {return}
        guard let children = listingData["children"] as? Array<[String:Any]> else { return }
        
        //thing is not my term
        for thing in children {
            
            if let commentData = thing["data"] as? [String:Any] {
                
                self.replyBody = commentData["body"] as? String ?? ""
                print(self.replyBody)
                
                if let replies = commentData["replies"] as? [String:Any],
                   let repliesData = replies["data"] as? [String:Any],
                   let childReplies = repliesData["children"] as? Array<[String:Any]>  {
                    for reply in childReplies {
                        commentReplies.append(RedditComment(listing: reply))
                    }
                }
                //TODO: handle child links: e0adqgo
            }
        }
    }
}
