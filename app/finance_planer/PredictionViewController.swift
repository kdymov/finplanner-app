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
        fillChart(chartData: threeMonthOutcomes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGroupedByTypeOutcomes(from month: String) -> [String:Double] {
        var result = [String:Double]()
        var url = "http://localhost:8000/outcomes/\(token)/"
        let request1: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        
        let dateFormatYearMonth = DateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        
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
                            
                            let current = dateFormatYearMonth.string(from: datedate!)
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
        let sum = [Double](chartData.values).reduce(0, +)
        var i = 0
        for (_, val) in chartData {
            let percent = Double(val) / sum
            let entry = ChartDataEntry(x: percent, y: Double(i))
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
    
    func getPrevMonths() -> [String] {
        let now = Date()
        let monthAgo = NSCalendar.current.date(byAdding: .month, value: -1, to: Date())
        let twoMonthsAgo = NSCalendar.current.date(byAdding: .month, value: -2, to: Date())
        
        let dateFormatYearMonth = DateFormatter()
        dateFormatYearMonth.dateFormat = "yyyy-MM"
        
        return [dateFormatYearMonth.string(from: twoMonthsAgo!), dateFormatYearMonth.string(from: monthAgo!), dateFormatYearMonth.string(from: now)]
    }
}
