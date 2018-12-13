//
//  TimelineViewController.swift
//  BarChart
//
//  Created by Nguyen Vu Nhat Minh on 19/8/17.
//Sources:
/*
 Nguyen, Minh. 2017. “Building Your Own Chart in IOS — Part 1: Bar Chart.” Medium. 2017. https://medium.com/@leonardnguyen/build-your-own-chart-in-ios-part-1-bar-chart-e1b7f4789d70.
 
 Nguyen, Minh. 2017. “Building Your Own Chart in IOS — Part 2: Line Chart.” Medium. 2017. https://medium.com/@leonardnguyen/building-your-own-chart-in-ios-part-2-line-chart-7b5cfc7c866.
*/
//

import UIKit
import Firebase
import os.log


class TimelineViewController: UIViewController, DataProtocolClient {
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    @IBOutlet weak var lineChart: MultiLineChart!
    @IBOutlet weak var happyCorrectPercent: UILabel!
    @IBOutlet weak var happyIncorrectPercent: UILabel!
    @IBOutlet weak var happyCount: UILabel!
    @IBOutlet weak var sadCorrectPercent: UILabel!
    @IBOutlet weak var sadIncorrectPercent: UILabel!
    @IBOutlet weak var sadCount: UILabel!
    @IBOutlet weak var angryCorrectPercent: UILabel!
    @IBOutlet weak var angryIncorrectPercent: UILabel!
    @IBOutlet weak var angryCount: UILabel!
    @IBOutlet weak var painCorrectPercent: UILabel!
    @IBOutlet weak var painIncorrectPercent: UILabel!
    @IBOutlet weak var unknownCorrectPercent: UILabel!
    @IBOutlet weak var painCount: UILabel!
    @IBOutlet weak var unknownIncorrectPercent: UILabel!
    @IBOutlet weak var unknownCount: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
    
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        // maybe I should move the call over here and then
        // reads from fb every time, maybe I should see if I can like save the data and no refresh ..
        //let chartdataEntries = generateRandomEntries()
        if let dataStack = dataStack {
            let newSeries = convertDataSeries(dataStack: dataStack)
            lineChart.dataEntries = newSeries
            lineChart.dataStack = dataStack //pass along the dataStack so we can use it 
            lineChart.isCurved = true
        }else{
            //lineChart.dataEntries = chartdataEntries
            //could implement that if I wanted
        }
        
        /*
 @IBOutlet weak var happyCorrectPercent: UILabel!
 @IBOutlet weak var happyIncorrectPercent: UILabel!
 @IBOutlet weak var happyCount: UILabel!
 @IBOutlet weak var sadCorrectPercent: UILabel!
 @IBOutlet weak var sadIncorrectPercent: UILabel!
 @IBOutlet weak var sadCount: UILabel!
 @IBOutlet weak var angryCorrectPercent: UILabel!
 @IBOutlet weak var angryIncorrectPercent: UILabel!
 @IBOutlet weak var angryCount: UILabel!
 @IBOutlet weak var painCorrectPercent: UILabel!
 @IBOutlet weak var painIncorrectPercent: UILabel!
 @IBOutlet weak var unknownCorrectPercent: UILabel!
 @IBOutlet weak var painCount: UILabel!
 @IBOutlet weak var unknownIncorrectPercent: UILabel!
 @IBOutlet weak var unknownCount: UILabel!
 */
        if let dataStack = dataStack, let predictions = dataStack.predictions {
            //let count = predictions.count
            //print(count)
            let happys = predictions.filter {
                $0.mood == Prediction.moods.happy
            }
            let sads = predictions.filter {
                $0.mood == Prediction.moods.sad
                }
            let angries = predictions.filter {
                $0.mood == Prediction.moods.angry
                }
            let pains = predictions.filter {
                $0.mood == Prediction.moods.pain
                }
            let unknowns = predictions.filter {
                $0.mood == Prediction.moods.unknown
                }
            
            happyCount.text = String(happys.count)
            if(happys.count>0){
                happyCorrectPercent.text = String((happys.filter{$0.confirmed == true}.count/happys.count)*100)+"%"
                happyIncorrectPercent.text = String(happys.filter{$0.confirmed == true}.count/happys.count)
            }else{
                happyCorrectPercent.text = "-"
                happyIncorrectPercent.text = "-"
            }
            
            

            sadCount.text = String(sads.count)
            if(sads.count>0){
                sadCorrectPercent.text = String((sads.filter{$0.confirmed == true}.count/sads.count)*100)+"%"
                sadIncorrectPercent.text = String((sads.filter{$0.confirmed == false}.count/sads.count)*100)+"%"
            }else{
                sadCorrectPercent.text = "-"
                sadIncorrectPercent.text = "-"
            }
            
            if(angries.count>0){
                angryCorrectPercent.text = String((angries.filter{$0.confirmed == true}.count/angries.count)*100)+"%"
                angryIncorrectPercent.text = String((angries.filter{$0.confirmed == false}.count/angries.count)*100)+"%"
            }else{
                angryCorrectPercent.text = "-"
                angryIncorrectPercent.text = "-"
            }
            angryCount.text = String(angries.count)
            
            if(pains.count>0){
                painCorrectPercent.text = String((pains.filter{$0.confirmed == true}.count/pains.count)*100)+"%"
                painIncorrectPercent.text = String((pains.filter{$0.confirmed == false}.count/pains.count)*100)+"%"
            }else{
                painCorrectPercent.text = "-"
                painIncorrectPercent.text = "-"
            }
            painCount.text = String(pains.count)
            
            if(unknowns.count>0){
                unknownCorrectPercent.text = String((unknowns.filter{$0.confirmed == true}.count/unknowns.count)*100)+"%"
                unknownIncorrectPercent.text = String((unknowns.filter{$0.confirmed == false}.count/unknowns.count)*100)+"%"
            }else{
                unknownCorrectPercent.text = "-"
                unknownIncorrectPercent.text = "-"
            }
            
            unknownCount.text = String(unknowns.count)
            
            
        }else{
            happyCorrectPercent.text = ""
            happyIncorrectPercent.text = ""
            happyCount.text = ""
            sadCorrectPercent.text = ""
            sadIncorrectPercent.text = ""
            sadCount.text = ""
            angryCorrectPercent.text = ""
            angryIncorrectPercent.text = ""
            angryCount.text = ""
            painCorrectPercent.text = ""
            painIncorrectPercent.text = ""
            unknownCorrectPercent.text = ""
            painCount.text = ""
            unknownIncorrectPercent.text = ""
            unknownCount.text = ""
        }
        happyCorrectPercent.sizeToFit()
        happyIncorrectPercent.sizeToFit()
        happyCount.sizeToFit()
        sadCorrectPercent.sizeToFit()
        sadIncorrectPercent.sizeToFit()
        sadCount.sizeToFit()
        angryCorrectPercent.sizeToFit()
        angryIncorrectPercent.sizeToFit()
        angryCount.sizeToFit()
        painCorrectPercent.sizeToFit()
        painIncorrectPercent.sizeToFit()
        unknownCorrectPercent.sizeToFit()
        painCount.sizeToFit()
        unknownIncorrectPercent.sizeToFit()
        unknownCount.sizeToFit()
        
       
        //
        /*
         // will need to move this till after I get the FB Data
        lineChart.dataEntries = dataEntries
        */
        /*
        let dataEntries = generateDataEntries()
        basicBarChart.dataEntries = dataEntries
        barChart.dataEntries = dataEntries
        */
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //gradientLayer.frame = view.bounds
        //maybe I can attach a listener on the OTHER one?
    }
    
    
    //generates entries from a set of data
    private func convertDataSeries(dataStack: DataStack) -> [String:[PointEntry3]] {
        var bpmarr:[PointEntry3] = []
        var gsrarr:[PointEntry3] = []
        var temparr:[PointEntry3] = []
        let data = dataStack.data
        let formatter = DateFormatter()
        //formatter.dateFormat = "h:mm a d MMM yy"
        formatter.dateFormat = "H:mm:ss d/MM"
        if let data = data {
            for datum in data {
                let date = Date(timeIntervalSince1970: datum.time)
                bpmarr.append(PointEntry3(value: Float(datum.bpm), label: formatter.string(from: date), time: datum.time))//keep the time? //only use one of the labels
                gsrarr.append(PointEntry3(value: Float(datum.gsr), label: formatter.string(from: date), time: datum.time))//keep the time?
                temparr.append(PointEntry3(value:Float(datum.temp), label: formatter.string(from: date), time: datum.time))//keep the time?
            }
        }
        let result:[String:[PointEntry3]] = ["bpm":bpmarr, "gsr":gsrarr, "temp":temparr]
        return result
    }
}
