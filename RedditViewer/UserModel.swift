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
    
    //TODO: Refactor this out
    //static var to track currently logged-in user
    static var currentUser: String? = nil

    //returns an array of usernames
    static var usernames: Array<String> {
        get {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let accountFetch = NSFetchRequest<NSManagedObject>(entityName: "Account")
            
            var results: [NSManagedObject] = []
            
            //query coredata database
            do {
                results = try context.fetch(accountFetch)
            } catch {
                print("error fetching accounts from coredata")
            }
            return results.filter({ ($0 as! Account).username != nil }).map({ ($0 as! Account).username! })
        }
    }
    
    //MARK: Properties
    private var dbContext: NSManagedObjectContext?
    private var token: OAuthToken?
    private(set) var username: String?
    
    var accessToken: String? {  //returns accesstoken or nil if expired
        get {
            loadAccount(UserModel.currentUser)
            
            if let expiration = token?.expires_in, expiration.timeIntervalSinceNow > 0 {
                return token?.access_token
            }
            return nil
        }
        
    }
    
    
    init() {
        dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadAccount()
    }
    
    
    //loads account info from coredata database, or sets to nil
    private func loadAccount(_ username: String?=nil){
        //load first account in core data
        if let context = dbContext,
        let account = getFirstAccount(context: context, username: username) {
            
            self.username = account.username
            UserModel.currentUser = account.username
            
            token = OAuthToken(account: account)
        }
        else {
            self.username = nil
            UserModel.currentUser = nil
            token = nil
        }
    }
    
    
    //deletes user profile, returns true if successful
    func logout(user: String?) -> Bool{
        //default to username if passed nil
        let logoutName = user ?? self.username
        
        if let logoutName = logoutName, let context = dbContext {
            
            let accountFetch = NSFetchRequest<NSManagedObject>(entityName: "Account")
            accountFetch.predicate = NSPredicate(format: "username == %@", logoutName)
            
            var results: [NSManagedObject] = []
            
            //query coredata database
            do {
                results = try context.fetch(accountFetch)
            } catch {
                print("error fetching accounts from coredata")
                return false
            }
            if let account = results.first {
                context.delete(account)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                print(logoutName + " deleted")
                loadAccount()
                return true
            }
        }
        return false
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
    func saveCredentials(_ json: [String:Any], completionBlock:@escaping () -> Void ) {
        
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
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            DispatchQueue.main.async {
                
                self?.username = name
                UserModel.currentUser = name
                print("UserModel: \(name) saved")
                
                completionBlock()
                
            }
            
            return
        }
    }
}
