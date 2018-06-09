//
//  userModel.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/5/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit
import CoreData

class UserModel {
    
    //MARK: Properties
    private var dbContext: NSManagedObjectContext?
    private var token: OAuthToken?
    private(set) var username: String?
    
    //returns accesstoken or nil if expired
    var accessToken: String? {
        get {
            if let expiration = token?.expires_in, expiration.timeIntervalSinceNow > 0 {
                return token?.access_token
            }
            return nil
        }
        
    }
    
    init() {
        
        dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //load first account in core data
        if let context = dbContext, let account = getFirstAccount(context: context, username: nil){
            username = account.username
            
            token = OAuthToken(account: account)
        }
    }
    

    //returns the first account in context, accepts username
    private func getFirstAccount(context: NSManagedObjectContext, username: String?=nil) -> Account? {
        
        let accountFetch = NSFetchRequest<NSManagedObject>(entityName: "Account")
        
        //filter by username if we have it
        if let username = username {
            accountFetch.predicate = NSPredicate(format: "username == %@", username)
        }
        
        var results: [NSManagedObject] = []
        
        //query coredata database
        do {
            results = try context.fetch(accountFetch)
        } catch {
            print("error fetching accounts from coredata")
            return nil
        }
        
        //set account to either the first or a new account if none
        return results.first as? Account
    }
    
    
    //MARK - Save Credentials
    //calls API to get username and updates existing or saves new
    func saveCredentials(_ json: [String:Any] ){
        
        token = OAuthToken(json: json)
        
        guard let token = token else {
            print("UserModel: token not initialized")
            return
        }
        
        //get username from reddit
        APICalls.getJSON(via: APICalls.redditRequest(endpoint: "/api/v1/me", token: token.access_token )){
            [weak self] jsonObject in
            
            guard let json = jsonObject as? [String:Any] else {return}
            
            guard let name = json["name"] as? String else {
                print("UserModel: could not get name from json")
                return
            }
            
            guard let context = self?.dbContext else {
                print("UserModel: could not unwrap dbcontext")
                return
            }
            
            //set account to either the first or a new account if none
            let account = self?.getFirstAccount(context: context, username: name) ?? Account(context: context)
            
            //update account info
            account.username = name
            account.refresh_token = token.refresh_token
            account.expires = token.expires_in as NSDate?
            account.token = token.access_token
            
            self?.username = name
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            print("UserModel: account saved")
            
            return
        }
    }
}
