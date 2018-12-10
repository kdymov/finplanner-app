//
//  RegistrationViewController.swift
//  finance_planer
//
//  Created by Nastya on 5/16/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var PasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let color = UIColor.red
        UsernameTextField.layer.borderWidth = 1.0
        PasswordTextField.layer.borderWidth = 1.0
        UsernameTextField.layer.borderColor = color.cgColor
        PasswordTextField.layer.borderColor = color.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : @escaping (_ succeeded: Bool, _ msg: String) -> ()) {
        var request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        
        request.httpMethod = "POST"
        
        var err: NSError?
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Body: \(strData)")
                var err: NSError?
                do {
                    var json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                    
                    var msg = "No message"
                    
                    if err != nil {
                        print(err!.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error could not parse JSON: '\(jsonStr)'")
                        postCompleted(false, "Error")
                    } else {
                        if let parseJSON = json {
                            if let success = parseJSON["success"] as? Bool {
                                print("Success: \(success)")
                                postCompleted(success, "Logged in.")
                            }
                            return
                        } else {
                            let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            print("Error could not parse JSON: \(jsonStr)")
                            postCompleted(false, "Error")
                        }
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
    
    @IBAction func signUpEvent(_ sender: UIButton) {
        let username = UsernameTextField.text
        let password = PasswordTextField.text
        print("sign_up" + username! + password!)
        
        if username != nil && password != nil{
            self.post(params: ["username":username!,"password":password!], url: "http://localhost:8000/users/") { (succeeded: Bool, msg: String) -> () in
                self.UsernameTextField.text = ""
                self.PasswordTextField.text = ""
                if succeeded {
                    print("Message from server \(msg)")
                }
            }
        }
    }
}
