//
//  ViewController.swift
//  finance_planer
//
//  Created by Nastya on 4/10/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var get_strd_btn: UIButton!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButtonOutlet.layer.borderWidth = 2.0
        loginButtonOutlet.layer.borderColor = UIColor.red.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                                print("Succes: \(success)")
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
    
    @IBAction func getStartedEvent(_ sender: Any) {
        print("getStarted")
    }
    
    @IBAction func login(_ sender: Any) {
        print("logining")
    }
}

