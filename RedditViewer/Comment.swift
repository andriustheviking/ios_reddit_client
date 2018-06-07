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
        
        self.replyBody = listingData["body"] as? String ?? ""


        if let repliesListing = listingData["replies"] as? [String:Any],
        let repliesData = repliesListing["data"] as? [String:Any],
        let repliesChildren = repliesData["children"] as? Array<[String:Any]>{
            for reply in repliesChildren {
                commentReplies.append(RedditComment(listing: reply))
            }
        }
        //TODO: handle child links: e0adqgo

    }
}
