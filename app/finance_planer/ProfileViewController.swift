//
//  ProfileViewController.swift
//  finance_planer
//
//  Created by Nastya on 5/16/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var currentMonthOutcomes: UILabel!
    @IBOutlet weak var progressOutcomes: UIProgressView!
    @IBOutlet weak var progressBarLimit: UILabel!
    @IBOutlet weak var limitTextField: UITextField!
    
    var getLimit: String = ""
    
    func get(url : String, postCompleted : (_ succeeded: Bool, _ msg: String) -> ()) -> Double {
        var result = 0.0
        let request1: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil
        do {
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1 as URLRequest, returning: response)
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: dataVal, options: []) as? NSDictionary {
                    print("Synchronous \(jsonResult)")
                    if let limitValue = jsonResult["limit"] {
                        result = Double(truncating: limitValue as! NSNumber)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return result
    }
    
    func getCurrentMonthOutcomes(url : String) -> Double {
        var result = 0.0
        let request1: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil
        let now = NSDate()
        let dateFormatMonth = DateFormatter()
        dateFormatMonth.dateFormat = "MM"
        let currentMonth = dateFormatMonth.string(from: now as Date)
        
        do {
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1 as URLRequest, returning: response)
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: dataVal, options: []) as? NSArray {
                    print("Synchronous \(jsonResult)")
                    for var item in jsonResult {
                        var currentItem = item as! NSDictionary
                        if let amount = currentItem["amount"], let date = currentItem["date"] {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let datedate = dateFormatter.date(from: date as! String)
                            let dateMonth = dateFormatMonth.string(from: datedate!)
                            if dateMonth == currentMonth {
                                result += Double(amount as! NSNumber)
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return result
    }

    
    func post(params : Dictionary<String, String>, url : String, postCompleted : @escaping (_ succeded: Bool, _ msg: String) -> ()) {
        var request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        
        request.httpMethod = "POST"
        if getLimit != "0.0" && getLimit != limitTextField.text {
            request.httpMethod = "PUT"
        }
        
        var err: NSError?
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                self.getLimit = self.limitTextField.text!
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Body: \(strData)")
                var err: NSError?
                do {
                    var json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                    
                    var msg = "No message"
                    
                    if (err != nil) {
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

    @IBAction func editLimitEvent(_ sender: UIButton) {
        if let limit = limitTextField.text {
            self.post(params: ["user":token,"limit":limit], url: "http://localhost:8000/accounts/") { (succeeded: Bool, msg: String) -> () in
                print(msg)
                self.progressBarLimit.text = self.limitTextField.text
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.red
        limitTextField.layer.borderWidth = 1.0
        limitTextField.layer.borderColor = color.cgColor
        
        if token == "" {
            sleep(1)
        }
        if token != "" {
            let limit = self.get(url: "http://localhost:8000/accounts/\(token)/") { (succeeded: Bool, msg: String) -> () in
                print(msg)
            }
            let outcomes = self.getCurrentMonthOutcomes(url: "http://localhost:8000/outcomes/\(token)/")
            currentMonthOutcomes.text = String(outcomes)
            progressOutcomes.progress = Float(outcomes) / Float(limit)
            limitTextField.text = String(limit)
            getLimit = limitTextField.text!
            progressBarLimit.text = limitTextField.text
        } else {
            limitTextField.text = String(0.0)
            getLimit = limitTextField.text!
            progressBarLimit.text = limitTextField.text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
