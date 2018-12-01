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
    
    /*
    
    override func viewDidAppear(animated: Bool) {
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            loginButtonOutlet.userInteractionEnabled = false
            
        }
        else{
            loginButtonOutlet.userInteractionEnabled = true
        }
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.redColor()
        
        usernameTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderWidth = 1.0
        
        usernameTextField.layer.borderColor = color.CGColor
        passwordTextField.layer.borderColor = color.CGColor
        
       
        

        // Do any additional setup after loading the view.
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
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        print("POST result \(jsonResult)")
                        token = String(jsonResult["token"])
                        token = token.substringWithRange(token.startIndex.advancedBy(9)..<token.endIndex.advancedBy(-1))
                        postCompleted(succeeded: true, msg: token)
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

    
    
    
    

    @IBAction func loginEvent(sender: UIButton) {
        
        var username = usernameTextField.text
        var password = passwordTextField.text
        
        if username != nil && password != nil{
            print("\(username!) \(password!)")
            self.post(["username":username!,"password":password!], url: "http://localhost:8000/api-token-auth/") { (succeeded: Bool, msg: String) -> () in
                print(msg)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
