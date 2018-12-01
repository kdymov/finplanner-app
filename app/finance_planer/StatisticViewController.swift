//
//  StatisticViewController.swift
//  finance_planer
//
//  Created by Nastya on 5/16/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit
import Charts

public enum OutcomesGroup {
    case Day
    case Month
    case Year
}

class StatisticViewController: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!
    
    var xAxis: [String]!
    var currentGroup: OutcomesGroup = .Day
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let chartData = getGroupedOutcomes(by: currentGroup)
        xAxis = [String](chartData.keys).sort(<)
        var yAxis = [Double]()
        for item in xAxis {
            yAxis.append(chartData[item]!)
        }
        setChart(xAxis, values: yAxis)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGroupedOutcomes(by groupingItem: OutcomesGroup) -> [String:Double] {
        var result = [String:Double]()
        var url = "http://localhost:8000/outcomes/\(token)/"
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        
        let now = NSDate()
        let dateFormatYearMonth = NSDateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        let dateFormatDay = NSDateFormatter()
        dateFormatDay.dateFormat = "dd"
        let dateFormatYear = NSDateFormatter()
        dateFormatYear.dateFormat = "yyyy"
        let dateFormatMonth = NSDateFormatter()
        dateFormatMonth.dateFormat = "MM"

        let currentYearMonth = dateFormatYearMonth.stringFromDate(now)
        let currentYear = dateFormatYear.stringFromDate(now)
        
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
                            switch groupingItem {
                                case .Day:
                                    let current = dateFormatYearMonth.stringFromDate(datedate!)
                                    if current == currentYearMonth {
                                        let currentDay = dateFormatDay.stringFromDate(datedate!)
                                        if let currentAmount = result[currentDay] {
                                            result[currentDay] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentDay] = (amount as! Double)
                                        }
                                    }
                                case .Month:
                                    let current = dateFormatYear.stringFromDate(datedate!)
                                    if current == currentYear {
                                        let currentMonth = dateFormatMonth.stringFromDate(datedate!)
                                        if let currentAmount = result[currentMonth] {
                                            result[currentMonth] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentMonth] = (amount as! Double)
                                        }
                                }
                                case .Year:
                                    let currentYear = dateFormatYear.stringFromDate(datedate!)
                                    if let currentAmount = result[currentYear] {
                                        result[currentYear] = currentAmount + (amount as! Double)
                                    } else {
                                        result[currentYear] = (amount as! Double)
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
    
    func setChart(dataPoints: [String], values: [Double]) {
        //barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        var chartLabel = ""
        if currentGroup == .Day {
            chartLabel = "Daily outcomes"
        } else if currentGroup == .Month {
            chartLabel = "Month outcomes"
        } else if currentGroup == .Year {
            chartLabel = "Year outcomes"
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: chartLabel)
        let chartData = BarChartData(xVals: xAxis, dataSet: chartDataSet)
        barChartView.data = chartData
    }
    @IBAction func DayOutcomesEvent(sender: UIButton) {
        if currentGroup != .Day {
            currentGroup = .Day
            
            let chartData = getGroupedOutcomes(by: currentGroup)
            xAxis = [String](chartData.keys).sort(<)
            var yAxis = [Double]()
            for item in xAxis {
                yAxis.append(chartData[item]!)
            }
            setChart(xAxis, values: yAxis)
        }
    }
    
    @IBAction func MonthOutcomesEvent(sender: UIButton) {
        if currentGroup != .Month {
            currentGroup = .Month
            
            let chartData = getGroupedOutcomes(by: currentGroup)
            xAxis = [String](chartData.keys).sort(<)
            var yAxis = [Double]()
            for item in xAxis {
                yAxis.append(chartData[item]!)
            }
            setChart(xAxis, values: yAxis)
        }
    }
    
    @IBAction func YearOutcomesEvent(sender: UIButton) {
        if currentGroup != .Year {
            currentGroup = .Year
            
            let chartData = getGroupedOutcomes(by: currentGroup)
            xAxis = [String](chartData.keys).sort(<)
            var yAxis = [Double]()
            for item in xAxis {
                yAxis.append(chartData[item]!)
            }
            setChart(xAxis, values: yAxis)
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

