//
//  TimelineViewController.swift
//  BarChart
//
//  Created by Nguyen Vu Nhat Minh on 19/8/17.
//  Copyright © 2017 Nguyen Vu Nhat Minh. All rights reserved.
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
    
    
    //generates entries from a set of data
    private func convertDataSeries(dataStack: DataStack) -> [String:[PointEntry3]] {
        var bpmarr:[PointEntry3] = []
        var gsrarr:[PointEntry3] = []
        var temparr:[PointEntry3] = []
        let data = dataStack.data
        let formatter = DateFormatter()
        //formatter.dateFormat = "h:mm a d MMM yy"
        formatter.dateFormat = "H:mm d/MM"
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

//I don't think I'm using this
public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
