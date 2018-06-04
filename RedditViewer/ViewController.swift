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
            //make sure not nil
            guard let tkn = token else { return }
            
            //store user info as asynchronous Background GCD task
            DispatchQueue.global(qos: .background).async {
                [weak tkn] in
                //get context

                //get username from reddit
                APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/api/v1/me", token: tkn?.access_token )){ json in

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
                    account.refresh_token = tkn?.refresh_token
                    account.expires = tkn?.expires_in as NSDate?
                    account.token = tkn?.access_token
                    
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    print("account saved")
                    
                    return
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


    
    @IBAction func something(_ sender: UIBarButtonItem) {
        
        
        guard let tok = token?.access_token else { return }
        
        let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let accountFetch = NSFetchRequest<NSManagedObject>(entityName: "Account")
        accountFetch.predicate = NSPredicate(format: "token == %@", tok)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try dbContext.fetch(accountFetch)
            if let account = results.first as? Account{
                print("user: \(account.username) saved in coredata")
            }else {
                print ("could not find username with token: \(tok)")
            }
            
        } catch {
            print("error fetching accounts from coredata")
            return
        }
        

        
//        getSubreddits()
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


//MARK - Request Reddit Data 
extension ViewController {
    
    //request front page
    func getSubreddits(){
        
//        let json: [String: Any]
        
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/subreddits/mine.json", token: token?.access_token )){
            json in
            
            print (json)
            
            return
        }
    }
    
    
    //delegate retrieves OAuth Token with code
    func receivedCredentials(code: String? ){
        if let code = code {
            //store json response for token via closure
            APICalls.getJSON(via: APICalls.tokenRequest(code: code)) {
                [weak self] json in
                
                //TODO handle errors from reddit
                
                print (json)
                self?.token = OAuthToken(json: json)
                
                //update UI with token
            }
        }
    }
}


//MARK - Populate Table
extension ViewController {
    
    //make request for front page
    
    
    
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
