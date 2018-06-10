//
//  EditProfileViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/10/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    var username = ""
    
    weak var userModel: UserModel?
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profileSwitch: UISwitch!

    @IBAction func makeCurrent(_ sender: UISwitch) {
        UserModel.currentUser = username
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        //log out from user model

        
        if let didLogout = userModel?.logout(user: username) {
            if didLogout {
                let _ = navigationController?.popViewController(animated: true)
            }
        }
        else {
            print ("EditProfile: Could not logout")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileSwitch.isOn = username == UserModel.currentUser
        
        usernameLabel.text = username
    }

}
