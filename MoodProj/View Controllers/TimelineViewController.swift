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


class TimelineViewController: UIViewController {
    

    @IBOutlet weak var barChart: BeautifulBarChart!
    @IBOutlet weak var lineChart: MultiLineChart!
    
    //public so I can fuss with it from the chart see MultiLineChart.swift
    
    var fbdata = DataSnapshot()
    var newdata = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // maybe I should move the call over here and then
        // reads from fb every time, maybe I should see if I can like save the data and no refresh ..
        getDataFromFB()
        let chartdataEntries = generateRandomEntries()
        lineChart.dataEntries = chartdataEntries
        lineChart.isCurved = true
        /*
         // will need to move this till after I get the FB Data
        lineChart.dataEntries = dataEntries
        lineChart.isCurved = true
        */
        /*
        let dataEntries = generateDataEntries()
        basicBarChart.dataEntries = dataEntries
        barChart.dataEntries = dataEntries
        */
    }
    
    public func popupViewText() {
        print("popupview")
    }
    
    func getDataFromFB() {
        let database = Database.database().reference()
        
        //this gets it, but I think I would have to like save this and then make it into data entries
        NSLog("Reading from DB")
        database.child("test").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            //print(snapshot)
            let value = snapshot.value as? NSDictionary
            //print(value)
            if value != nil{
                let dataEntries = self.doDataEntries(dict: value!)
                //self.basicBarChart.dataEntries = dataEntries
                //self.barChart.dataEntries = dataEntries //hiding for class
            }else{
                print ("didn't get any data")
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func doDataEntries(dict: NSDictionary)->[BarEntry] {
        //right now this should look the same
        //print(dict.count)
        var result: [BarEntry] = []
        
        let sortedDict = dict.sorted {
            // this sorting is kinda working, but the resulting info is pretty cray.
            
            let one = $0.value as AnyObject
            let two = $1.value as AnyObject
            
            
            if let t1 = one["time"], let t1a = t1, let t2 = two["time"], let t2a = t2 {
                
                let tt1 = t1a as! Double
                let tt2 = t2a as! Double
                
                return tt1 > tt2
                /*
                if(tt1 > tt2){
                    // first time is further in the future than the last time
                    print("\(tt1) is greater than \(tt2) so return TRUE")
                 re_urn true
                }else{
                    print("\(tt1) is less than \(tt2) so return FALSE")
                    return false
                }*/
            } else { 
                return false
            }
            
        }
        
        
        for (_, v) in sortedDict {
            let nv = v as AnyObject
            //print(nv)
            var bpm = nv["bpm"]
            var gsr = nv["gsr"]
            var temp = nv["temp"]
            var time = nv["time"]
            var value:Int32? = 0
            var date = Date()
            var color = UIColor(hue: 0, saturation: 1, brightness: 0, alpha: 1)
            if let ubpm = bpm, let uubpm = ubpm{
                //print(uubpm)
                bpm = uubpm
                if let v = (uubpm as? NSString)?.intValue {
                    //print("Value set")
                    value = v
                }
            }
            if let ugsr = gsr, let uugsr = ugsr {
                //print(uugsr)
                gsr = uugsr
            }
            if let utemp = temp, let uutemp = utemp {
                //print(uutemp)
                if let t = (uutemp as? NSString)?.floatValue {
                    //print("Value set")
                    temp = t
                }
                let h = Rescale(from: (25, 35), to: (0, 1.0)).rescale(temp as! Float)
                color = UIColor(hue: CGFloat(h), saturation: 1, brightness: 1, alpha: 1)
            }
            if let utime = time, let uutime = utime {
                //maybe I could check the time and skip it if it's too old?
                //print(uutime)
                time = uutime
                date = Date(timeIntervalSince1970: time as! TimeInterval)
            }
            
            let height: Float = Float(value!) / 100.0
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d h:mm a" // probably need to add some time on to here
            
            result.append(BarEntry(color: color, height: height, textValue: "\(value!)", title: formatter.string(from: date)))
        }
        /*
        for i in 0..<20 {
            let value = (arc4random() % 90) + 10
            let height: Float = Float(value) / 100.0
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))
            result.append(BarEntry(color: colors[i % colors.count], height: height, textValue: "\(value)", title: formatter.string(from: date)))
        }
        */
        print(dict.count)
        return result
    }
    
    func generateDataEntries() -> [BarEntry] {
        let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
        var result: [BarEntry] = []
        for i in 0..<20 {
            let value = (arc4random() % 90) + 10
            let height: Float = Float(value) / 100.0
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))
            result.append(BarEntry(color: colors[i % colors.count], height: height, textValue: "\(value)", title: formatter.string(from: date)))
        }
        return result
    }
    
    private func generateRandomEntries() -> [PointEntry] {
        var result: [PointEntry] = []
        for i in 0..<100 {
            let value = Int(arc4random() % 500)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))
            
            result.append(PointEntry(value: value, label: formatter.string(from: date)))
        }
        return result
    }
}

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
