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
        var xAxis = [String](chartData.keys)
        xAxis.sort(by: <)
        var yAxis = [Double]()
        for item in xAxis {
            yAxis.append(chartData[item]!)
        }
        setChart(dataPoints: xAxis, values: yAxis)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGroupedOutcomes(by groupingItem: OutcomesGroup) -> [String:Double] {
        var result = [String:Double]()
        var url = "http://localhost:8000/outcomes/\(token)/"
        let request1: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        
        let now = NSDate()
        let dateFormatYearMonth = DateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        let dateFormatDay = DateFormatter()
        dateFormatDay.dateFormat = "dd"
        let dateFormatYear = DateFormatter()
        dateFormatYear.dateFormat = "yyyy"
        let dateFormatMonth = DateFormatter()
        dateFormatMonth.dateFormat = "MM"

        let currentYearMonth = dateFormatYearMonth.string(from: now as Date)
        let currentYear = dateFormatYear.string(from: now as Date)
        
        do {
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1 as URLRequest, returning: response)
            
            do {
                // print(NSString(data: dataVal, encoding: NSUTF8StringEncoding))
                
                if let jsonResult = try JSONSerialization.jsonObject(with: dataVal, options: []) as? NSArray {
                    print("Synchronous \(jsonResult)")
                    for var item in jsonResult {
                        var currentItem = item as! NSDictionary
                        if let amount = currentItem["amount"], let date = currentItem["date"] {
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let datedate = dateFormatter.date(from: date as! String)
                            switch groupingItem {
                                case .Day:
                                    let current = dateFormatYearMonth.string(from: datedate!)
                                    if current == currentYearMonth {
                                        let currentDay = dateFormatDay.string(from: datedate!)
                                        if let currentAmount = result[currentDay] {
                                            result[currentDay] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentDay] = (amount as! Double)
                                        }
                                    }
                                case .Month:
                                    let current = dateFormatYear.string(from: datedate!)
                                    if current == currentYear {
                                        let currentMonth = dateFormatMonth.string(from: datedate!)
                                        if let currentAmount = result[currentMonth] {
                                            result[currentMonth] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentMonth] = (amount as! Double)
                                        }
                                }
                                case .Year:
                                    let currentYear = dateFormatYear.string(from: datedate!)
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
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
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
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: chartLabel)
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }
    
    @IBAction func DayClick(_ sender: Any) {
        if currentGroup != .Day {
            currentGroup = .Day
            
            let chartData = getGroupedOutcomes(by: currentGroup)
            var xAxis = [String](chartData.keys)
            xAxis.sort(by: <)
            var yAxis = [Double]()
            for item in xAxis {
                yAxis.append(chartData[item]!)
            }
            setChart(dataPoints: xAxis, values: yAxis)
        }
    }
    
    @IBAction func MonthClick(_ sender: Any) {
        if currentGroup != .Month {
            currentGroup = .Month
            
            let chartData = getGroupedOutcomes(by: currentGroup)
            var xAxis = [String](chartData.keys)
            xAxis.sort(by: <)
            var yAxis = [Double]()
            for item in xAxis {
                yAxis.append(chartData[item]!)
            }
            setChart(dataPoints: xAxis, values: yAxis)
        }
    }
    
    @IBAction func YearClick(_ sender: Any) {
        if currentGroup != .Year {
            currentGroup = .Year
            
            let chartData = getGroupedOutcomes(by: currentGroup)
            var xAxis = [String](chartData.keys)
            xAxis.sort(by: <)
            var yAxis = [Double]()
            for item in xAxis {
                yAxis.append(chartData[item]!)
            }
            setChart(dataPoints: xAxis, values: yAxis)
        }
    }
}

