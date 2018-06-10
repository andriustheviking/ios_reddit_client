//
//  MyPostsTableViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/8/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class MyPostsTableViewController: UITableViewController {
   
    var posts = Array<[String: Any]>()
    
    let user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //connect tablview to custom table cell
        let nib = UINib.init(nibName: "RedditPostTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MyPostCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //get submitted posts
        getSubmissions()
    }

    
    @IBAction func showPosts(_ sender: UIBarButtonItem) {
        getSubmissions()
    }
    

    //MARK: - Request Reddit Data
    //request front page
    func getSubmissions(){
        
        if let token = user.accessToken, let username = UserModel.currentUser {
            
            print("getSubmissions called with username: \(username)")
            
            let apiRequest = APICalls.redditRequest(endpoint: "/user/\(username)/submitted", token: token )
            
            
            APICalls.getJSON(via: apiRequest){
                [weak self] jsonSerialized in
                
                guard let json = jsonSerialized as? [String:Any] else { return }

                self?.posts.removeAll(keepingCapacity: true)
                
                guard let listings = json["data"] as? [String:Any] else { return }
                
                for post in (listings["children"] as? Array<[String:Any]>)! {
                    if let postData = (post["data"] as? [String : Any]) {
    //                    print(postData)
                        self?.posts.append(postData )
                    }
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()

                return
                }
            } //end of closure
        }
        else {
            posts.removeAll()
            tableView.reloadData()
            let alert = UIAlertController(title: nil, message: "You must be logged in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else { return }
        
        switch id {
        
        case "newPostSegue":   fallthrough
        case "editPostSegue":
            
            let vc = segue.destination as! PostViewController
            
            vc.token = user.accessToken
            
            if (id == "editPostSegue") {
                guard let row = sender as? Int else { return }
                vc.post = postData(post: posts[row])
            }
        default:
            break
        }
    }
}



// MARK: - Table view data source
extension MyPostsTableViewController {
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostCell", for: indexPath) as! RedditPostTableCell

        let post = posts[indexPath.row]
        
        let title = post["title"] as? String
        let author = post["subreddit"] as? String
        
        cell.postTitle.text = title
        cell.subreddit.text = author

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editPostSegue", sender: indexPath.row)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}

/*
extension MyPostsTableViewController: TabBarSelectable {
    //NOTE: this fires when unselected
    func selectedByTabBar(){

    }
}
 */
