
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
    var token: String?
    
    //stores existing post data if available
    var post: postData? = nil
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subredditField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyTextField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //populate with existing post, if available
        if let post = post {
            
            subredditField.isHidden = true
            titleField.isHidden = true
            
            subredditLabel.text = "Subreddit: /r/" + post.subreddit
            titleLabel.text = "Title: " + post.title
            bodyTextField.text = post.bodyText
            
            navBar.title = "Edit Post"
        }
    }
    
    
    @IBAction func submitPost(_ sender: UIButton) {
        
        guard let body = bodyTextField.text else { return }
        
        //if post, edit existing post
        if let name = post?.name {
            editPost(name: name, body: body)
            let _ = navigationController?.popViewController(animated: true)
        }
        else {
            if let sr = subredditField.text,
            let title = titleField.text {
                createPost(to: sr, title: title, body: body)
                let _ = navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func deletePost(_ sender: UIBarButtonItem) {
        if let name = post?.name {
            deletePost(name: name)
            let _ = navigationController?.popViewController(animated: true)
        }
    }
}




extension PostViewController {
    
    func deletePost(name: String){
        let urlbody = "id=" + name
        
        if let token = token {
            
            print("PostVC: createPost token: \(token)")
            
            let submitRequest = APICalls.redditRequest(endpoint: "/api/del", token: token, method: "POST", body: urlbody)
            
            APICalls.getJSON(via: submitRequest){
                serializedJson in
                print ( serializedJson as! [String:Any] )
            }
        }
    }
    
    func editPost(name: String, body: String){
        guard let safeBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed ) else {return}

        var urlbody = "api_type=json"
        urlbody += "&thing_id=" + name
        urlbody += "&text=" + safeBody
        
        if let token = token {
            
            print("PostVC: createPost token: \(token)")
            
            let submitRequest = APICalls.redditRequest(endpoint: "/api/editusertext", token: token, method: "POST", body: urlbody)
            
            APICalls.getJSON(via: submitRequest){
                serializedJson in
                print ( serializedJson as! [String:Any] )
            }
        }
    }
    
    
    func createPost(to subreddit: String, title: String, body: String){
        
        guard let safeSub = subreddit.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed ),
            let safeTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed ),
            let safeBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed ) else {return}
        
        var urlbody = ""
        urlbody += "api_type=json"
        urlbody += "&kind=self"
        urlbody += "&resubmit=true"
        urlbody += "&send_replies=true"
        urlbody += "&sr=" + safeSub
        urlbody += "&title=" + safeTitle
        urlbody += "&text=" + safeBody
        
        print(urlbody)
        
        if let token = token {

            let submitRequest = APICalls.redditRequest(endpoint: "/api/submit.json", token: token, method: "POST", body: urlbody)
            
            APICalls.getJSON(via: submitRequest){
                serializedJson in
                print ( serializedJson as! [String:Any] )
            }
        }
    }
}
