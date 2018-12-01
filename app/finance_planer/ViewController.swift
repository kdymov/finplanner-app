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
        // Do any additional setup after loading the view, typically from a nib.
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"budgetchart.png")!)
        /*get_strd_btn.frame = CGRectMake(100,100,100,50)
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "budgetchart.png")?.drawInRect(self.view.bounds)
        

        let background = UIImage(named: "bg.jpg")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = self.view.center
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView) */
        
        loginButtonOutlet.layer.borderWidth = 2.0
        loginButtonOutlet.layer.borderColor = UIColor.redColor().CGColor
        
        
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
    
    @IBAction func getStartedEvent(sender: AnyObject) {
        print("getStarted")
        
        
        /*self.post(["user":"de5204a286004f7304af08b0e40abc7f45fd6517", "limit":"5000"], url: "http://localhost:8000/accounts/") { (succeeded: Bool, msg: String) -> () in
            print(msg)
        }*/
        
        // get all outcome types 
        /*
        let urlPath: String = "http://localhost:8000/outcometypes/"
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        do{
            
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            
            do {
                // print(NSString(data: dataVal, encoding: NSUTF8StringEncoding))
                
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? NSArray {
                    print("Synchronous \(jsonResult)")
                    for var item in jsonResult {
                        if let type_name = item["type"] {
                            print(type_name!)
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
            
        }catch let error as NSError
        {
            print(error.localizedDescription)
        } */

    }
    
    @IBAction func login(sender: AnyObject) {
        print("logining")
    }
    

}

