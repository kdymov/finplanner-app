//
//  PieChartViewController.swift
//  finance_planer
//
//  Created by Nastya on 5/20/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit
import Charts

class PieChartViewController: UIViewController {
    @IBOutlet weak var pieChartView: PieChartView!
    
    var currentGroup: OutcomesGroup = .Day
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let chartData = getGroupedByTypeOutcomes(from: currentGroup)
        fillChart(chartData)
    }
    @IBAction func yearOutcomesEvent(sender: UIButton) {
        if currentGroup != .Year {
            currentGroup = .Year
            let chartData = getGroupedByTypeOutcomes(from: currentGroup)
            fillChart(chartData)
        }
    }
    @IBAction func monthOutcomesEvent(sender: UIButton) {
        if currentGroup != .Month {
            currentGroup = .Month
            let chartData = getGroupedByTypeOutcomes(from: currentGroup)
            fillChart(chartData)
        }
    }
    @IBAction func dayOutcomesEvent(sender: UIButton) {
        if currentGroup != .Day {
            currentGroup = .Day
            let chartData = getGroupedByTypeOutcomes(from: currentGroup)
            fillChart(chartData)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGroupedByTypeOutcomes(from timeSpan: OutcomesGroup) -> [String:Double] {
        var result = [String:Double]()
        var url = "http://localhost:8000/outcomes/\(token)/"
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        
        let now = NSDate()
        let dateFormatYearMonthDay = NSDateFormatter()
        dateFormatYearMonthDay.dateFormat = "yyyy-MM-dd"
        let dateFormatYearMonth = NSDateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        let dateFormatYear = NSDateFormatter()
        dateFormatYear.dateFormat = "yy"
        
        let currentYearMonthDay = dateFormatYearMonthDay.stringFromDate(now)
        let currentYearMonth = dateFormatYearMonth.stringFromDate(now)
        let currentYear = dateFormatYear.stringFromDate(now)
        
        do{
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            
            do {
                // print(NSString(data: dataVal, encoding: NSUTF8StringEncoding))
                
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? NSArray {
                    print("Synchronous \(jsonResult)")
                    for var item in jsonResult {
                        if let amount = item["amount"], let date = item["date"], let type = item["type"] {
                            
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let datedate = dateFormatter.dateFromString(date as! String)
                            switch timeSpan {
                                case .Day:
                                    let current = dateFormatYearMonthDay.stringFromDate(datedate!)
                                    if current == currentYearMonthDay {
                                        let currentType = type as! String
                                        if let currentAmount = result[currentType] {
                                            result[currentType] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentType] = (amount as! Double)
                                        }
                                    }
                                case .Month:
                                    let current = dateFormatYearMonth.stringFromDate(datedate!)
                                    if current == currentYearMonth {
                                        let currentType = type as! String
                                        if let currentAmount = result[currentType] {
                                            result[currentType] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentType] = (amount as! Double)
                                        }
                                    }
                                case .Year:
                                    let current = dateFormatYear.stringFromDate(datedate!)
                                    if current == currentYear {
                                        let currentType = type as! String
                                        if let currentAmount = result[currentType] {
                                            result[currentType] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentType] = (amount as! Double)
                                        }
                                }
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
    
    func fillChart(chartData: [String:Double]) {
        var dataEntries = [ChartDataEntry]()
        let sum = [Double](chartData.values).reduce(0, combine: +)
        var i = 0
        for (_, val) in chartData {
            let percent = Double(val) / sum
            let entry = ChartDataEntry(value: percent, xIndex: i)
            i = i + 1
            dataEntries.append(entry)
        }
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 5
        
        let chartData = PieChartData(xVals: [String](chartData.keys), dataSet: chartDataSet)
        
        pieChartView.data = chartData
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
