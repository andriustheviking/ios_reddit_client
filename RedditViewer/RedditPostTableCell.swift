//
//  RedditPostTableCell.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/31/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class RedditPostTableCell: UITableViewCell {

    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var subreddit: UILabel!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
