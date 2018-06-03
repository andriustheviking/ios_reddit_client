//
//  ViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/24/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OAuthCredentialDelegate {

    var token: OAuthToken?
    
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
        if let t = token?.access_token {
            print("Token="+t)
        }
        else {
            print("Token=nil")
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


//MARK - Request Reddit Data 
extension ViewController {
    
    
    //delegate retrieves OAuth Token with code
    func receivedCredentials(code: String? ){
        
        if let code = code {
            
            //store json response for token via closure
            APICalls.getJSON(via: APISpecs.tokenRequest(code: code)) { json in
                print ("inside completion block:")
                print (json)
                self.token = OAuthToken(json: json)
                
                //t creates reference loop
                if let t = self.token?.access_token {
                    print("Token="+t)
                }
                else {
                    print("Token=nil")
                }
                
                //update UI with token
            }
        }
    }
}


//MARK - Populate Table
extension ViewController {
    
    
    
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
