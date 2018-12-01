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
    
    func get(url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) -> Double {
        var result = 0.0
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        
        do{
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            
            do {
                // print(NSString(data: dataVal, encoding: NSUTF8StringEncoding))
                
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? NSDictionary {
                    print("Synchronous \(jsonResult)")
                    if let limitValue = jsonResult["limit"] {
                        result = Double(limitValue as! NSNumber)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
            
        }catch let error as NSError
        {
            print(error.localizedDescription)
        }
        return result
    }
    
    func getCurrentMonthOutcomes(url : String) -> Double {
        var result = 0.0
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        let now = NSDate()
        let dateFormatMonth = NSDateFormatter()
        dateFormatMonth.dateFormat = "MM"
        let currentMonth = dateFormatMonth.stringFromDate(now)
        print(currentMonth)
        
        do{
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            
            do {
                // print(NSString(data: dataVal, encoding: NSUTF8StringEncoding))
                
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? NSArray {
                    print("Synchronous \(jsonResult)")
                    for var item in jsonResult {
                        if let amount = item["amount"], let date = item["date"] {
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let datedate = dateFormatter.dateFromString(date as! String)
                            let dateMonth = dateFormatMonth.stringFromDate(datedate!)
                            if dateMonth == currentMonth {
                                result += Double(amount as! NSNumber)
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
            
        }catch let error as NSError
        {
            print(error.localizedDescription)
        }
        return result
    }

    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        if getLimit != "0.0" && getLimit != limitTextField.text {
            request.HTTPMethod = "PUT"
        }
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                self.getLimit = self.limitTextField.text!
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

    @IBAction func editLimitEvent(sender: UIButton) {
        if let limit = limitTextField.text {
            self.post(["user":token,"limit":limit], url: "http://localhost:8000/accounts/") { (succeeded: Bool, msg: String) -> () in
                print(msg)
                self.progressBarLimit.text = self.limitTextField.text
            }
            /*
            self.get(url: "http://localhost:8000/accounts/de5204a286004f7304af08b0e40abc7f45fd6517/") { (succeeded: Bool, msg: String) -> () in
                print(msg)
            }
*/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.redColor()
        limitTextField.layer.borderWidth = 1.0
        limitTextField.layer.borderColor = color.CGColor
        
        

        // Do any additional setup after loading the view.
        if token == "" {
            sleep(1)
        }
        if token != "" {
            var limit = self.get("http://localhost:8000/accounts/\(token)/") { (succeeded: Bool, msg: String) -> () in
                print(msg)
            }
            var outcomes = self.getCurrentMonthOutcomes("http://localhost:8000/outcomes/\(token)/")
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
