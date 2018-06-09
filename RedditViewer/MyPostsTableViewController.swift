//
//  MyPostsTableViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/8/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class MyPostsTableViewController: UITableViewController {

    var user = UserModel() //gets user info at init
    
    var posts = Array<[String: Any]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        if let name = user.username {
            print("getting posts")
            getSubmissions(for: name)
        }
        else {
            print("couldn't get posts")
        }
    }


    //MARK: - Request Reddit Data
    //request front page
    func getSubmissions(for username: String){
        print("getSubmissions called with username: \(username)")
        
        var apiRequest = APICalls.redditRequest(endpoint: "/user/\(username)/submitted", token: user.accessToken )
        
        
        
        APICalls.getJSON(via: apiRequest){
            [weak self] jsonSerialized in
            
            guard let json = jsonSerialized as? [String:Any] else { return }
            
            self?.posts.removeAll(keepingCapacity: true)
            
            guard let listings = json["data"] as? [String:Any] else { return }
            
            for post in (listings["children"] as? Array<[String:Any]>)! {
                if let postData = (post["data"] as? [String : Any]) {
                    print(postData)
                    self?.posts.append(postData )
                }
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()

            return
            }
        } //end of closure
    }
}



// MARK: - Table view data source
extension MyPostsTableViewController {
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
