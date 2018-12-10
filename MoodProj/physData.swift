//
//  Prediction.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation
import UIKit
import os.log


class PhysData: NSObject, NSCoding {
    
    enum gsrstate: String, CaseIterable {
        case sf = "Few Small Peaks" // small and few
        case sm  = "Many Small Peaks" // small and many
        case bs = "Some Big Peaks" // big and some
        case bo = "One Big Peak" // big and one
        case none = "None" // so I can set it when I have noting
    }
    
    
    //MARK: Properties
    
    var millis: Double
    var time: TimeInterval
    var gsr: CGFloat
    var gsreval: gsrstate? // maybe make this an iterable
    var bpm: Int
    var temp: Double
    
    struct PropertyKey {
        static let millis = "millis"
        static let time = "time"
        static let gsr = "gsr"
        static let gsreval = "gsreval"
        static let bpm = "bpm"
        static let temp = "temp"
    }
    
    //MARK: Initialization
    
    init?(millis: Double, time: TimeInterval, gsr: CGFloat, gsreval: gsrstate?, bpm: Int, temp: Double ) {
        //I could do some work here to make sure they fit nicely
        self.millis = millis
        self.time = time
        self.gsr = gsr
        self.gsreval = gsreval
        self.bpm = bpm
        self.temp = temp
    }
    
    func returnMoodPrediction(baseline:[String:Float])->Prediction.moods {
        var mood: Prediction.moods
        mood = Prediction.moods.unknown
        //from the paper:
        //I can get a lot deeper into this, this is going to be a pretty barebones implementation, and probably one with a lot of room on the outside. Also I can't implement the confidence score.
        //I'm assuming 5 is a line between small and large dicrease or decrease
        if let bbpm = baseline["bpm"], let bgsr = baseline["gsr"], let btemp = baseline["temp"]{
            let diffbpm = Float(self.bpm)-bbpm
            //let diffgsr = Float(self.gsr)-bgsr
            let difftemp = Float(self.temp)-btemp
            
            //add the gsr peaks in here
            if(diffbpm>=0 && difftemp<=0){
                //HR is increasing, temp is decreasing (both should be "slight"), need to add EDA increase and EDA peaks small&few
                mood = Prediction.moods.happy
            }else if (diffbpm<=0 && abs(diffbpm)>=5 && difftemp<=0){
                //HR is decreasing "bigly", temp is decreasing (should check for slightness), need to add EDA increase and EDA peaks small&many
                mood = Prediction.moods.sad
            }else if(diffbpm<=0 && abs(diffbpm)<5 && difftemp<=0){
                //HR is decreasing "slightly", temp is decreasing (should check for slightness), need to add EDA increase and EDA peaks big&some
                mood = Prediction.moods.angry
            }else if(diffbpm == 0 && difftemp == 0){
                //HR is unchanged, skintemp is unchanged, need to add EDA increase and EDA peaks big&one
                mood = Prediction.moods.pain
            }else{
                //we're off the map
                mood = Prediction.moods.unknown
            }
        }else{
            print("something is not right")
            mood = Prediction.moods.unknown
        }
        return mood
    }
    
    //I will be swapping this out with a thing for sending to FB
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.millis, forKey: PropertyKey.millis)
            print(self.millis)
        aCoder.encode(self.time, forKey: PropertyKey.time)
        aCoder.encode(self.gsr, forKey: PropertyKey.gsr)
        /*
        if let gsreval = self.gsreval {
            aCoder.encode("\(gsreval)", forKey: PropertyKey.gsreval)
        }else{
            aCoder.encode("none", forKey: PropertyKey.gsreval)
        }*/
        aCoder.encode(self.bpm, forKey: PropertyKey.bpm)
        aCoder.encode(self.temp, forKey: PropertyKey.temp)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        /*
 var millis: Double
 var time: TimeInterval
 var gsr: CGFloat
 var gsreval: gsrstate? // maybe make this an iterable
 var bpm: Int
 var temp: Double
 */
        print("trying to load dataPoint")
        //let m = aDecoder.decodeObject(forKey: PropertyKey.millis) as Double? // did you not get saved???
        
        let mm = aDecoder.decodeObject(forKey: PropertyKey.millis) as? Double
        print("Millis: \(mm)")

        guard let millis2 = aDecoder.decodeObject(forKey: PropertyKey.millis) as? Double else {
            os_log("Unable to decode the millis for a PhysData object.", log: OSLog.default, type: .debug)
            return nil
        }
        let time = aDecoder.decodeDouble(forKey: PropertyKey.time)
        let bpm = aDecoder.decodeCInt(forKey: PropertyKey.bpm)
        
        //the gsr is required.
        guard let gsr = aDecoder.decodeObject(forKey: PropertyKey.gsr) as? CGFloat else {
            os_log("Unable to decode the gsr for a PhysData object.", log: OSLog.default, type: .debug)
            return nil
        }
        //bpm is required
        /*
        guard let bpm = aDecoder.decodeCInt(forKey: PropertyKey.bpm) as? Int32 else {
            os_log("Unable to decode the bpm for a PhysData object.", log: OSLog.default, type: .debug)
            return nil
        }
        */
        //temp is required
        guard let temp = aDecoder.decodeObject(forKey: PropertyKey.temp) as? Double else {
            os_log("Unable to decode the temp for a PhysData object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        //let gsreval = aDecoder.decodeObject(forKey: PropertyKey.gsreval) as? gsrstate
        let gsreval = PhysData.gsrstate.sf
        
        // Must call designated initializer.
        self.init(millis: millis2, time: time, gsr:gsr, gsreval:gsreval, bpm: Int(bpm), temp:temp)
    }
}
