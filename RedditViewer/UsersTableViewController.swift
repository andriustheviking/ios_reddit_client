//
//  UsersTableViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/9/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class UsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user = UserModel()

    @IBOutlet weak var preambleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib.init(nibName: "UsersTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "usernameCell")
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let loggedInUser = UserModel.currentUser {
            preambleLabel.text = "Logged In As:"
            userLabel.text = loggedInUser
        } else {
            preambleLabel.text = ""
            userLabel.text = "No Current Accounts"
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return UserModel.usernames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "usernameCell", for: indexPath) as! UsersTableViewCell
        
        cell.username.text = UserModel.usernames[indexPath.row]

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editProfile", sender: indexPath.row)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK: - Segue Handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {return}
        
        switch id {
            
        case "getAuthorization":
            let vc = segue.destination as! OAuthViewController
            vc.credentialDelegate = self
        
        case "editProfile":
            let vc = segue.destination as! EditProfileViewController
            guard let row = sender as? Int else { return }
            vc.username = UserModel.usernames[row]
            vc.userModel = user
            
        default:
            return
        }
    }
}



extension UsersTableViewController: OAuthCredentialDelegate {
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
                }
            }
        }
    }
}
