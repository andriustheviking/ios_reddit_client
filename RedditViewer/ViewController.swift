//
//  ViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/24/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, OAuthCredentialDelegate {

    var token: OAuthToken? {
        //update Account info
        didSet {
            //store user info as asynchronous Background GCD task
            DispatchQueue.global(qos: .background).async {
                [weak self] in
                if let tkn = self?.token {
                    self?.saveCredentials(withToken: tkn)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad fired")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear fired")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews fired")
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

    
    
    //TODO: Populate table with reddit post
    
    
    
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
        
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/subreddits/mine.json", token: token?.access_token )){
            json in
            
            print (json)
            
            return
        }
    }
}


extension ViewController {
    //MARK - Save Credentials
    //calls API to get username and saves info to CoreData
    func saveCredentials(withToken token: OAuthToken){
        
        //get username from reddit
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/api/v1/me", token: token.access_token )){ json in
            
            guard let username = json["name"] as? String else {return}
            
            let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let accountFetch = NSFetchRequest<NSManagedObject>(entityName: "Account")
            accountFetch.predicate = NSPredicate(format: "username == %@", username)
            
            var results: [NSManagedObject] = []
            
            do {
                results = try dbContext.fetch(accountFetch)
            } catch {
                print("error fetching accounts from coredata")
                return
            }
            
            //set account to either the first or a new account if none
            let account = results.first as? Account ?? Account(context: dbContext)
            
            //update account info
            account.username = username
            account.refresh_token = token.refresh_token
            account.expires = token.expires_in as NSDate?
            account.token = token.access_token
            
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


extension String {
    //random string generator: stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
