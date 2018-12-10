//
//  fbdata.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-12-04.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation
import Firebase

func getFireBaseData(finished: @escaping (NSDictionary?) -> ()) {
    
    print("Doing something!")
    let database = Database.database().reference()
    
    var nv = NSDictionary()
    database.child("test").observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? NSDictionary
        if let value = value {
            nv = value
        }
        if nv.allValues.isEmpty {
            finished(nil)
        }else {
            finished(value)
        }
        
    }) { (error) in
        print(error.localizedDescription)
    }
}

func convertDictToPhysData(values: NSDictionary?)->[PhysData]{
    var result: [PhysData] = []
    
    
    if let values = values {
        let sortedDict = values.sorted {
            //sorting function timesort in sorting.swift
            return timesort(one: $0.value as AnyObject, two: $1.value as AnyObject)
        }
        
        for (_, v) in sortedDict {
            let nv = v as AnyObject
            //print(nv)
            var bpm = nv["bpm"]
            var gsr = nv["gsr"]
            var temp = nv["temp"]
            var time = nv["time"]
            var millis = nv["millis"]
            let gsrstatus = nv["gsrstatus"]
            
            var b: Int32 = 0
            var m: Double = 0
            var te: Double = 0
            var ti: TimeInterval = 0
            var g: CGFloat = 0
            //need one for the new gsr thing that isn't a thing yet
            
            //var value:Int32? = 0
            //var date = Date()
            //color I should do in the part where I'm converting it to the stuff for the MultiLineChart, not here
            //could also break this stuff out into a function
            if let ubpm = bpm, let uubpm = ubpm{
                //print(uubpm)
                bpm = uubpm
                if let v = (uubpm as? NSString)?.integerValue {
                    bpm = v
                    b = Int32(v)
                }
            }
            if let ugsr = gsr, let uugsr = ugsr {
                //print(uugsr)
                gsr = uugsr
                if let gs = (uugsr as? NSString)?.floatValue {
                    //print("Value set")
                    gsr = gs
                    g = CGFloat(Float(gs))
                }
            }
            if let utemp = temp, let uutemp = utemp {
                //print(uutemp)
                if let t = (uutemp as? NSString)?.floatValue {
                    temp = t
                    te = Double(t)
                }
            }
            if let utime = time, let uutime = utime {
                //maybe I could check the time and skip it if it's too old?
                //print(uutime)
                time = uutime
                time = Date(timeIntervalSince1970: time as! TimeInterval)
                if let utime2 = (uutime as? Double) {
                    ti = TimeInterval(utime2)
                }
            }
            if let umillis = millis, let uumillis = umillis {
                //maybe I could check the time and skip it if it's too old?
                //print(uutime)
                if let millis2 = (uumillis as? NSString)?.doubleValue {
                    m = millis2
                    millis = millis2
                }
            }
            if let gsrstatus = gsrstatus {
                //print(gsrstatus)
            }
            
            if let item = (PhysData(millis: m, time: ti, gsr: g, gsreval: nil, bpm: Int(b), temp: te)){
                result.append(item)
            }
        }
    }
    return result
}

