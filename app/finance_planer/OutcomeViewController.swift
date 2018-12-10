//
//  OutcomeViewController.swift
//  finance_planer
//
//  Created by Nastya on 5/16/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit

class OutcomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var sumDatePicker: UIDatePicker!
    @IBOutlet weak var typesPickerView: UIPickerView!
    
    var pickerData = [String]()
    
    var selectedType = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.red
        sumTextField.layer.borderWidth = 1.0
        sumTextField.layer.borderColor = color.cgColor
        
        self.allTypes()
        
        self.typesPickerView.delegate = self
        self.typesPickerView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    func allTypes() -> Void {
        var types = NSArray()
        
        let urlPath: String = "http://localhost:8000/outcometypes/"
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(url: url as URL)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil
        do {
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1 as URLRequest, returning: response)
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: dataVal, options: []) as? NSArray {
                    print("Synchronous \(jsonResult)")
                    types = jsonResult
                    for var item in jsonResult {
                        var currentItem = item as! NSDictionary
                        if let type_name = currentItem["type"] {
                            print(type_name)
                            pickerData.append(type_name as! String)
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = row + 1
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
                var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Body: \(strData)")
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        print("POST result \(jsonResult)")
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

    @IBAction func outcomeSubmitEvent(_ sender: UIButton) {
        var amount = sumTextField.text!
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var selectedDate = dateFormatter.string(from: sumDatePicker.date)
        
        self.post(params: ["type":String(selectedType),"user":token,"date":selectedDate,"amount":amount], url: "http://localhost:8000/outcomes/") { (succeeded: Bool, msg: String) -> () in
            print(msg)
        }
    }
}
