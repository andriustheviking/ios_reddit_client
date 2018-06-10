//
//  ViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/24/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var user = UserModel()  //gets user info at init
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

        case "openSubreddit":
            let vc = segue.destination as! SubredditViewController
            vc.user = user
            
            
            guard let postNum = redditFeedTableView.indexPathForSelectedRow?.row else { return }
             let post = posts[ postNum ]
        
            guard let url = post["url"] as? String else {return}
            guard let display_name = post["display_name"] as? String else {return}
        
            vc.subreddit = display_name
            vc.subredditUrl = url
        
        default:
            break
        }
    }

    
    
//MARK: - Request Reddit Data
    //request front page
    func getSubreddits(){
        
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/subreddits/mine/subscriber", token: user.accessToken )){
            [weak self] jsonObject in
//            print(json)
            guard let json = jsonObject as? [String:Any] else { return }
            
            //MARK: TEMP - clear out out array
            self?.posts.removeAll(keepingCapacity: true)
            
            guard let listings = json["data"] as? [String:Any] else { return }
            
//            print(listings)
            
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
        
        let name = post["display_name"] as? String ?? "Title Error"
        let subreddit = post["subreddit"] as? String ?? ""
        
        cell.postTitle.text = name
        cell.subreddit.text = subreddit
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openSubreddit", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    

}

