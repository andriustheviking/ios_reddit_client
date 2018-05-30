//
//  ViewController.swift
//  RedditViewer
//
//  Created by Andrius Kelly on 5/24/18.
//  Copyright © 2018 Andrius Kelly. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OAuthCredentialDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func receivedCredentials(state: String?, code: String? ){
        print( "State: " + ( state ?? "nil" ) )
        print ( "Code: " + (code ?? "nil"))
    }
    
    
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
