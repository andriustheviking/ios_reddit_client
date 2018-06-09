//
//  PostViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 6/9/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    var navBarText = "New Text Post" {
        didSet {
            navBar.title = navBarText
        }
        
    }
    
    var postName: String? = nil
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var subredditField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyTextField: UITextView!
    
    @IBAction func submitPost(_ sender: UIButton) {
    }
    
    @IBAction func deletePost(_ sender: UIBarButtonItem) {
        if let _ = postName {
            //delete post
        }
        //pop off view controller
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
