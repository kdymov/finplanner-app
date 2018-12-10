//
//  LoginViewController.swift
//  finance_planer
//
//  Created by Nastya on 5/16/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit

public var token = ""

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.red
        
        usernameTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderWidth = 1.0
        
        usernameTextField.layer.borderColor = color.cgColor
        passwordTextField.layer.borderColor = color.cgColor
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : @escaping (_ succeeded: Bool, _ msg: String) -> ()) {
        var request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        var session = URLSession.shared
        
        request.httpMethod = "POST"
        
        var err: NSError?
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Body: \(strData)")
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        print("POST result \(jsonResult)")
                        token = String(jsonResult["token"] as! String)
                        var x =
                        //token = token.substring(with: token.index(token.startIndex, offsetBy: 9)..<token.index(token.endIndex, offsetBy: -1))
                        postCompleted(true, token)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    @IBAction func loginEvent(_ sender: UIButton) {
        var username = usernameTextField.text
        var password = passwordTextField.text
        
        if username != nil && password != nil{
            print("\(username!) \(password!)")
            self.post(params: ["username":username!,"password":password!], url: "http://localhost:8000/api-token-auth/") { (succeeded: Bool, msg: String) -> () in
                print(msg)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
