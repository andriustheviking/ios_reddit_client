//
//  SubredditViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/8/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class SubredditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //TODO refactor out user model into delegate
    weak var user: UserModel?
    var posts = Array<[String: Any]>()
    var subreddit: String?
    var subredditUrl: String?
    
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postsTableView.delegate = self
        postsTableView.dataSource = self
        
        navBarTitle.title = subreddit
        if let url = subredditUrl {
            getPosts(for: url)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {return}
        switch id {

        case "openComments":
            //grab selected cell number
            guard let postNum = postsTableView.indexPathForSelectedRow?.row else { return }
            
            let post = posts[postNum]
            
            guard let permalink = post["permalink"] as? String else { return }
            
            //pass user info and destination to segue
            let vc = segue.destination as! CommentsTableViewController
            vc.destination = permalink
            vc.user = user
            
        default:
            break
        }
    }
    

    //MARK: - Request Reddit Data
    //request front page
    func getPosts(for subreddit:String){
        
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: subreddit, token: user?.accessToken )){
            [weak self] jsonObject in
            //            print(json)
            guard let json = jsonObject as? [String:Any] else { return }
            
            //MARK: TEMP - clear out out array
            self?.posts.removeAll(keepingCapacity: true)
            
            guard let listings = json["data"] as? [String:Any] else { return }
            
            //append each post data to posts array
            for post in (listings["children"] as? Array<[String:Any]>)! {
                if let postData = (post["data"] as? [String : Any]) {
//                    print(postData)
                    self?.posts.append(postData )
                }
            }
            DispatchQueue.main.async {
                self?.postsTableView.reloadData()
            }
            return
        } //end of closure
    }
}



//MARK: TableView Functions
extension SubredditViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RedditPostTableCell", owner: self, options: nil)?.first as! RedditPostTableCell
        
        let post = posts[indexPath.row]
        
        let title = post["title"] as? String ?? "Title Error"
        let author = post["author"] as? String ?? ""
        
        cell.postTitle.text = title
        cell.subreddit.text = author
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openComments", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
