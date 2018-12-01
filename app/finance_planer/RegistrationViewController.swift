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

        // Do any additional setup after loading the view.
        let color = UIColor.redColor()
        UsernameTextField.layer.borderWidth = 1.0
        PasswordTextField.layer.borderWidth = 1.0
        UsernameTextField.layer.borderColor = color.CGColor
        PasswordTextField.layer.borderColor = color.CGColor
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                var err: NSError?
                do {
                    var json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                    
                    var msg = "No message"
                    
                    // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                    if(err != nil) {
                        print(err!.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                        postCompleted(succeeded: false, msg: "Error")
                    }
                    else {
                        // The JSONObjectWithData constructor didn't return an error. But, we should still
                        // check and make sure that json has a value using optional binding.
                        if let parseJSON = json {
                            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                            if let success = parseJSON["success"] as? Bool {
                                print("Succes: \(success)")
                                postCompleted(succeeded: success, msg: "Logged in.")
                            }
                            return
                        }
                        else {
                            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("Error could not parse JSON: \(jsonStr)")
                            postCompleted(succeeded: false, msg: "Error")
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

    
    
    
    
    
    @IBAction func signUpEvent(sender: UIButton) {
        var username = UsernameTextField.text
        var password = PasswordTextField.text
        print("sign_up" + username! + password!)
        
        if username != nil && password != nil{
            self.post(["username":username!,"password":password!], url: "http://localhost:8000/users/") { (succeeded: Bool, msg: String) -> () in
                self.UsernameTextField.text = ""
                self.PasswordTextField.text = ""
                if succeeded {
                    print("Message from server \(msg)")
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
