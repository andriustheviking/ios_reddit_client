//
//  CommentsTableViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/6/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {


    var destination: String?
    var subreddit: String?
    weak var user: UserModel?
    
    var comments = Array<RedditComment>()
    
    @IBOutlet weak var barTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //connect tablview to custom table cell
        let nib = UINib.init(nibName: "CommentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentCell")

        //get destination json request
        if let destination = destination {
            let commentsRequest = APICalls.redditRequest(endpoint: destination, token: user?.accessToken)

            APICalls.getJSON(via: commentsRequest){
                [weak self] jsonObject in
                
                if let post = jsonObject as? Array<Any>{
                    
                    //get content info
                    if let contentListing = post[0] as? [String:Any],
                        let listingData = contentListing["data"] as? [String:Any],
                    let listingChildren = (listingData["children"] as? Array<[String:Any]>)?.first,
                    let contentData = listingChildren["data"] as? [String:Any] {
                        
                        //this is the post content
                        print(contentData)
                        self?.subreddit = contentData["subreddit"] as? String
                    }
                    
                    
                    //store post comments as array of comment trees
                    if let commentsListing = post[1] as? [String:Any],
                    let commentsData = commentsListing["data"] as? [String:Any],
                    let listingChildren = commentsData["children"] as? Array<[String:Any]> {

                        print(listingChildren.first)
                        
                        for listing in listingChildren {
                            self?.comments.append(RedditComment(listing: listing))
                        }
                        
                        //fill tableview
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
                else {
                    print("CommentsTable: could not unwrap posts")
                }
            }
        }
    }

    
    override func viewWillLayoutSubviews() {
        //set the navbar title to the subreddit title
        barTitle.title = subreddit
    }
    
    
    
    //MARK: Segue Handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "newComment":
            let vc = segue.destination as! NewCommentViewController
            vc.postTitleContainer = "" //TODO: pass selected comment permalink
            vc.parentName = "" //TODO: pass selected comment name
        default:
            break
        }
    }
    
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell

        // Configure the cell...
        cell.commentText.text = comments[indexPath.row].replyBody
        cell.userName.text = comments[indexPath.row].author
        
        return cell
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
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
