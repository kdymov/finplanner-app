//
//  PredictionViewController.swift
//  finance_planer
//
//  Created by Nastya on 5/21/18.
//  Copyright © 2018 Nastya. All rights reserved.
//

import UIKit
import Charts

class PredictionViewController: UIViewController {

    @IBOutlet weak var outcomesValueLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var threeMonthOutcomes = [String:Double]()
        var months = getPrevMonths()
        var coeff = -2
        var sum = 0.0
        for var month in months {
            let typesOutcomes = getGroupedByTypeOutcomes(from: month)
            for var (key, val) in typesOutcomes {
                if let amount = threeMonthOutcomes[key] {
                    threeMonthOutcomes[key] = amount + Double(coeff) * val
                } else {
                    threeMonthOutcomes[key] = Double(coeff) * val
                }
            }
            coeff += 3
        }
        for var (key, _) in threeMonthOutcomes {
            if let amount = threeMonthOutcomes[key] {
                threeMonthOutcomes[key] = amount / 3
                sum += amount / 3
            }
        }
        
        outcomesValueLabel.text = String(format: "%.2f", sum)
        fillChart(threeMonthOutcomes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGroupedByTypeOutcomes(from month: String) -> [String:Double] {
        var result = [String:Double]()
        var url = "http://localhost:8000/outcomes/\(token)/"
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        
        let dateFormatYearMonth = NSDateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        
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
                            
                            let current = dateFormatYearMonth.stringFromDate(datedate!)
                            if current == month {
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
    
    func getPrevMonths() -> [String] {
        let now = NSDate()
        let monthAgo = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: -1, toDate: NSDate(), options: [])
        let twoMonthsAgo = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: -2, toDate: NSDate(), options: [])
        
        let dateFormatYearMonth = NSDateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        
        return [dateFormatYearMonth.stringFromDate(twoMonthsAgo!), dateFormatYearMonth.stringFromDate(monthAgo!), dateFormatYearMonth.stringFromDate(now)]
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
