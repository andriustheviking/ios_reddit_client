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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad fired")
        redditFeedTableView.delegate = self
        redditFeedTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear fired")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews fired")
    }
    
    
    //MARK: Outlets
    @IBOutlet weak var redditFeedTableView: UITableView!
    var dbContext: NSManagedObjectContext?
    var username: String?
    
    
    var token: OAuthToken? {
        //update Account info
        didSet {
            //store user info with asynchronous Background GCD task
            DispatchQueue.global(qos: .background).async {
                [weak self] in
                guard let tkn = self?.token else { return }
                self?.saveCredentials(withToken: tkn)
            }
        }
    }
    

    //MARK tester button
    @IBAction func something(_ sender: UIBarButtonItem) {
        
        let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let accountFetch = NSFetchRequest<NSManagedObject>(entityName: "Account")
        
        if let tok = token?.access_token {
            accountFetch.predicate = NSPredicate(format: "token == %@", tok)
        }
        var results: [NSManagedObject] = []
        
        do {
            results = try dbContext.fetch(accountFetch)
            if let account = results.first as? Account{
                print("\(results.count) accounts" )
                print("user: \(account.username!) saved in coredata with token=\(account.token!)")
            } else {
                print ("could not find users")
            }
            
        } catch {
            print("error fetching accounts from coredata")
            return
        }
    }
    
    
    //MARK: - Segue Handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {return}
        switch id {
            case "getAuthorization":
                let vc : OAuthViewController = segue.destination as! OAuthViewController
                vc.credentialDelegate = self
                
            default:
                break;
        }
    }
}



extension ViewController {
    //MARK - Request Reddit Data
    //request front page
    func getSubreddits(){
        
//      let json: [String: Any]
        
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/best", token: token?.access_token )){
            json in
            
            print (json)
            
            return
        }
    }
}


extension ViewController {
    //MARK - loadFirstCredential
    // loads first credential in database
    func loadFirstCredential(){
        return
    }
    
    //returns the first account in context, accepts username
    func getFirstAccount(context: NSManagedObjectContext, username: String?=nil) -> Account? {
        
        let accountFetch = NSFetchRequest<NSManagedObject>(entityName: "Account")
        
        if let username = username {
            accountFetch.predicate = NSPredicate(format: "username == %@", username)
        }
        
        var results: [NSManagedObject] = []
        
        do {
            results = try context.fetch(accountFetch)
        } catch {
            print("error fetching accounts from coredata")
            return nil
        }
        
        //set account to either the first or a new account if none
        return results.first as? Account
    }
}


extension ViewController {
    //MARK - Table View functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RedditPostTableCell", owner: self, options: nil)?.first as! RedditPostTableCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        return
    }

}


extension ViewController {
    //MARK - Save Credentials
    //calls API to get username and updates existing or saves new
    func saveCredentials(withToken token: OAuthToken){
        
        //get username from reddit
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/api/v1/me", token: token.access_token )){
            [weak self] json in
            
            guard let name = json["name"] as? String else { return }
            
            let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            //set account to either the first or a new account if none
            let account = self?.getFirstAccount(context: dbContext, username: name) ?? Account(context: dbContext)
            
            //update account info
            account.username = self?.username
            account.refresh_token = token.refresh_token
            account.expires = token.expires_in as NSDate?
            account.token = token.access_token
            
            self?.username = name
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            print("account saved")
            
            return
        }
    }
}



extension ViewController {
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
            [weak self] json in
            
            //TODO handle errors from reddit
            
            print (json)
            self?.token = OAuthToken(json: json)
        }
    }
}

