//
//  PostViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/9/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

struct postData {
    var name: String
    var subreddit: String
    var title: String
    var bodyText: String
    
    init?(post: [String:Any]) {
        
        guard let name = post["name"] as? String  else { return nil}
        guard let title = post["title"] as? String else { return nil}
        guard let body = post["selftext"] as? String else { return nil}
        guard let subreddit = post["subreddit"] as? String else { return nil}

        self.bodyText = body
        self.name = name
        self.subreddit = subreddit
        self.title = title
    }
}

class PostViewController: UIViewController {

    //stores existing post data if available
    var post: postData? = nil
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var subredditField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyTextField: UITextView!
    
    
    @IBAction func submitPost(_ sender: UIButton) {
        //if postName indicated, edit existing post
    }
    
    @IBAction func deletePost(_ sender: UIBarButtonItem) {
        if let _ = post {
            //delete post
        }
        //pop off view controller
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //populate with existing post, if available
        if let post = post {
            subredditField.text = post.subreddit
            titleField.text = post.title
            bodyTextField.text = post.bodyText
            
            navBar.title = "Edit Post"
        }
    }

}
