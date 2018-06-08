//
//  ViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/24/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, OAuthCredentialDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //Models
    var user = UserModel()
    //MARK: TODO - refactor posts into data model
    var posts = Array<[String: Any]>()
    

    
    //MARK: Outlets
    @IBOutlet weak var redditFeedTableView: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad fired")
        
        redditFeedTableView.delegate = self
        redditFeedTableView.dataSource = self
        
        if let _ = user.username {
            getSubreddits()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews fired")
    }
    
    

    //MARK: tester button
    @IBAction func something(_ sender: UIBarButtonItem) {
    
        getSubreddits()
    }
    
    
    //MARK: - Segue Handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {return}
        switch id {
            case "getAuthorization":
                let vc : OAuthViewController = segue.destination as! OAuthViewController
                vc.credentialDelegate = self
            
            case "openComments":
                //grab selected cell number
                guard let postNum = redditFeedTableView.indexPathForSelectedRow?.row else { return }
                
                let post = posts[postNum]

                guard let permalink = post["permalink"] as? String else { return }
                
                //pass user info and destination to segue
                let vc : CommentsTableViewController = segue.destination as! CommentsTableViewController
                vc.destination = permalink
                vc.user = user
            
            default:
                break;
        }
    }

    
    
//MARK: - Request Reddit Data
    //request front page
    func getSubreddits(){
        
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/best", token: user.accessToken )){
            [weak self] jsonObject in
//            print(json)
            guard let json = jsonObject as? [String:Any] else { return }
            
            //MARK: TEMP - clear out out array
            self?.posts.removeAll(keepingCapacity: true)
            
            guard let listings = json["data"] as? [String:Any] else { return }
            
            for post in (listings["children"] as? Array<[String:Any]>)! {
                if let postData = (post["data"] as? [String : Any]) {
//                    print(postData)
                    self?.posts.append(postData )
                }
            }
            DispatchQueue.main.async {
                self?.redditFeedTableView.reloadData()
            }
            
            return
        } //end of closure
    }

    
    
    
//MARK: - Table View functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RedditPostTableCell", owner: self, options: nil)?.first as! RedditPostTableCell
        
        let post = posts[indexPath.row]
        
        let title = post["title"] as? String ?? "Title Error"
        let subreddit = post["subreddit"] as? String ?? "Subreddit Error"
        
        cell.postTitle.text = title
        cell.subreddit.text = subreddit
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openComments", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //fix this
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    //MARK - OAuthCredentialDelegate
    //Requests OAuth Token with code and store json response via closure
    func receivedCredentials(code: String? ){
        guard let code = code else { return }
        
        var tokenRequest = APICalls.redditRequest(
            endpoint: "/api/v1/access_token",
            token: nil,
            method: "POST",
            body: "grant_type=authorization_code&code=\(code)&redirect_uri=\(Credentials.redirectURI)"
        )
        
        //add authorization header user:pass as clientId:secret
        let userPass = "\(Credentials.clientId):\(Credentials.secret)"
        guard let base64UserPass: String = (userPass.data(using: .utf8)?.base64EncodedString()) else { return }
        tokenRequest.setValue("Basic \(base64UserPass)", forHTTPHeaderField: "Authorization")
        
        APICalls.getJSON(via: tokenRequest) {
            [weak self] jsonObject in
            
            //MARK: TODO - handle errors from reddit
            
            //asyncronously update CoreData
            if let json = jsonObject as? [String:Any]{
                DispatchQueue.global(qos: .background).async {
                    [weak self] in
                    self?.user.saveCredentials(json)
                    self?.getSubreddits()
                }
            }
        }
    }
}

