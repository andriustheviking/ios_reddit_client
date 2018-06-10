
//
//  PostViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/9/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import Foundation
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

    //TODO: refactor out user to MVC model
    var user = UserModel()
    
    //stores existing post data if available
    var post: postData? = nil
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var subredditField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyTextField: UITextView!
    
    
    @IBAction func submitPost(_ sender: UIButton) {
        
        guard let sr = subredditField.text,
            let title = titleField.text,
            let body = bodyTextField.text else { return }
        
        //if post, edit existing post
        if let _ = post {
            //updatePost()
        }
        else {
            createPost(to: sr, title: title, body: body)
        }
        
        
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



extension PostViewController {
    
    func createPost(to subreddit: String, title: String, body: String){
        
        var json = "{"
        json += "\"api_type\":\"json\""
        json += "\"sr\":\"\(subreddit)\","
        json += "\"title\":\"\(title)\","
        json += "\"text\":\"\(body)\"}"
        

        let submitRequest = APICalls.redditRequest(endpoint: "/api/submit", token: user.accessToken, method: "POST", body: json )
        
        APICalls.getJSON(via: submitRequest){
            [weak self] serializedJson in
            print (serializedJson as! [String:Any] )
        }
        

    }
}
