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
        fillChart(groupedOutcomes: chartData)
    }
    
    @IBAction func dayClick(_ sender: Any) {
        if currentGroup != .Day {
            currentGroup = .Day
            let chartData = getGroupedByTypeOutcomes(from: currentGroup)
            fillChart(groupedOutcomes: chartData)
        }
    }
    
    @IBAction func monthClick(_ sender: Any) {
        if currentGroup != .Month {
            currentGroup = .Month
            let chartData = getGroupedByTypeOutcomes(from: currentGroup)
            fillChart(groupedOutcomes: chartData)
        }
    }
    
    @IBAction func yearClick(_ sender: Any) {
        if currentGroup != .Year {
            currentGroup = .Year
            let chartData = getGroupedByTypeOutcomes(from: currentGroup)
            fillChart(groupedOutcomes: chartData)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGroupedByTypeOutcomes(from timeSpan: OutcomesGroup) -> [String:Double] {
        var result = [String:Double]()
        var url = "http://localhost:8000/outcomes/\(token)/"
        let request1: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        
        let now = NSDate()
        let dateFormatYearMonthDay = DateFormatter()
        dateFormatYearMonthDay.dateFormat = "yyyy-MM-dd"
        let dateFormatYearMonth = DateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        let dateFormatYear = DateFormatter()
        dateFormatYear.dateFormat = "yy"
        
        let currentYearMonthDay = dateFormatYearMonthDay.string(from: now as Date)
        let currentYearMonth = dateFormatYearMonth.string(from: now as Date)
        let currentYear = dateFormatYear.string(from: now as Date)
        
        do{
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1 as URLRequest, returning: response)
            
            do {
                // print(NSString(data: dataVal, encoding: NSUTF8StringEncoding))
                
                if let jsonResult = try JSONSerialization.jsonObject(with: dataVal, options: []) as? NSArray {
                    print("Synchronous \(jsonResult)")
                    for var item in jsonResult {
                        var currentItem = item as! NSDictionary
                        if let amount = currentItem["amount"], let date = currentItem["date"], let type = currentItem["type"] {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let datedate = dateFormatter.date(from: date as! String)
                            switch timeSpan {
                                case .Day:
                                    let current = dateFormatYearMonthDay.string(from: datedate!)
                                    if current == currentYearMonthDay {
                                        let currentType = type as! String
                                        if let currentAmount = result[currentType] {
                                            result[currentType] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentType] = (amount as! Double)
                                        }
                                    }
                                case .Month:
                                    let current = dateFormatYearMonth.string(from: datedate!)
                                    if current == currentYearMonth {
                                        let currentType = type as! String
                                        if let currentAmount = result[currentType] {
                                            result[currentType] = currentAmount + (amount as! Double)
                                        } else {
                                            result[currentType] = (amount as! Double)
                                        }
                                    }
                                case .Year:
                                    let current = dateFormatYear.string(from: datedate!)
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
    
    func fillChart(groupedOutcomes: [String:Double]) {
        var dataEntries = [ChartDataEntry]()
        let sum = [Double](groupedOutcomes.values).reduce(0, +)
        var i = 0
        for (_, val) in groupedOutcomes {
            let percent = Double(val) / sum
            let entry = ChartDataEntry(x: Double(i), y: percent)
            i = i + 1
            dataEntries.append(entry)
        }
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 5
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        pieChartView.data = chartData
    }
}
