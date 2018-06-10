//
//  UsersTableViewCell.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/10/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
