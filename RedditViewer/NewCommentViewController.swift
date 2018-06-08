//
//  NewCommentViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/7/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit
import CoreData

class NewCommentViewController: UIViewController {

    var parentName: String? = nil
    
    //stores title until storyboard loads
    var postTitleContainer: String? = nil
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTitle.text = postTitleContainer
        
        if let parent = parentName {
        
            let dbContext =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            loadComment(for: parent, from: dbContext)
        
        //TODO: look for saved comment
        }
        else {
            //if no target, pop off viewcontroller
        }
    }


    deinit {
        if let parent = parentName {
            
            let dbContext =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            saveComment(for: parent, to: dbContext)
        }
    }


    func saveComment(for parent: String, to context: NSManagedObjectContext) {
        
        //retreive existing comment entity or create new
        let comment = getComment(of: parent, from: context) ?? Comment(context: context)
        
        comment.parent = parent
        comment.text = textField.text
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    //queries comment and populates text field, if exists
    func loadComment(for parent: String, from context: NSManagedObjectContext) {

        //fill in text field if exists
        if let comment = getComment(of: parent, from: context){
            textField.text = comment.text
        }
    }
    
    //returns saved comment or nil
    func getComment(of parent: String, from context: NSManagedObjectContext) -> Comment?{
        
        let commentFetch = NSFetchRequest<NSManagedObject>(entityName: "Comment")
        commentFetch.predicate = NSPredicate(format: "parent == %@", parent)
        
        var results: [NSManagedObject] = []
        
        //query coredata database
        do {
            results = try context.fetch(commentFetch)
            return results.first as? Comment ?? nil
        } catch {
            print("error fetching accounts from coredata")
            return nil
        }
    }
}
