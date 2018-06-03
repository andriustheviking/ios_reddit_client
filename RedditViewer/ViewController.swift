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

    //delegate retrieves OAuth Token with code
    func receivedCredentials(code: String? ){
        
        if let code = code {
            print ( "code: " + code)
        
            //pass token to retrieveToken func via closure
            AuthorizationToken.retrieveToken(withCode: code) { json in
                print ("inside completion block:")
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
    
    
    func saveToken(jsonResponse: [String:Any]?) {
        
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
     func retrieveToken(withCode code: String, completionBlock: @escaping (Data) -> Void) {
        
        let session = URLSession.shared
        guard let request = RedditSpecs.authTokenRequest(forCode: code) else {return}
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error  in
            
            guard error == nil else { return }
            
            guard let data = data else { return }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:String] {
                    print("in function call:")
                    print (jsonResponse)
                }
                else {
                    print ("could not objectify json")
                }
                
            } catch let error {
                //is error blocking code?
                print(error.localizedDescription)
            }
            
            print("task closure executed")
        })
        
        task.resume()
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
