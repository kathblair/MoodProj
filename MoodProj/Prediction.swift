//
//  Prediction.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
/*references
 
 Pollreisz, David, and Nima Taherinejad. 2017. “A Simple Algorithm for Emotion Recognition , Using Physiological Signals of a Smart Watch,” 2353–56.
 
 */
//

import Foundation
import UIKit
import os.log


class Prediction: NSObject, NSCoding {// probably will need to add codable
    
    enum moods: String, CaseIterable {
        case happy
        case sad
        case angry
        case pain
        case unknown
    }
    
    //MARK: Types
    
    struct PropertyKey {
        static let timecreated = "timecreated"
        static let mood = "mood"
        static let confirmed = "confirmed"
        static let note = "note"
        static let time = "time"
        static let millis = "millis"
        static let gsr = "gsr"
        static let gsreval = "gsreval"
        static let bpm = "bpm"
        static let temp = "temp"
    }
    
    
    
    //MARK: Properties
    
    //var timeofprediction: TimeInterval
    var timecreated: TimeInterval?
    var mood: moods //probably need one for a corrected mood too
    var confirmed: Bool? // if it's not set, it wasn't evaluated.
    var note: String?
    //var dataPoint: PhysData
    var time: TimeInterval
    var millis: Double
    var gsr: CGFloat
    var gsreval: PhysData.gsrstate? // maybe make this an iterable
    var bpm: Int
    var temp: Double
    var originalmood: moods? //only set it after confirmation with what the mood originally was, whether or not it was correct
    
    public static var MoodStrings = [
        "happy":"Happy",
        "sad":"Sad",
        "angry":"Angry",
        "pain":"In Pain",
        "unknown":"Other"

    ]
    
    public static var GSRStrings = [
        "fs":"Few Small Peaks",
        "ms":"Man Small Peaks",
        "sb":"Some Big Peaks",
        "ob":"One Big Peaks",
        "none":"No Peaks"
        
    ]
    
    //MARK: Initialization
    
    init?(timecreated: TimeInterval?, mood: moods, confirmed: Bool?, note: String?, time: TimeInterval, millis: Double, gsr: CGFloat, gsreval: PhysData.gsrstate?, bpm: Int, temp: Double) {
        self.timecreated = timecreated
        self.mood = mood
        self.confirmed = confirmed
        self.note = note
        //self.dataPoint = dataPoint
        self.time = time
        self.millis = millis
        self.gsr = gsr
        self.gsreval = gsreval // maybe make this an iterable
        self.bpm = bpm
        self.temp = temp
        
        super.init()
    }
    
    //could also send the function the format I want to use
    public func returnPredictionTimeText() -> String {
        // returns a string of the prediction time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        let date = Date(timeIntervalSince1970: self.time)
        return formatter.string(from: date)
    }
    
    //could also send the function the format I want to use
    public func returnPredictionDateText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let date = Date(timeIntervalSince1970: self.time)
        return formatter.string(from: date)
    }
    
    public func returnPredictionDateTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d h:mm:ss a"
        let date = Date(timeIntervalSince1970: self.time)
        return formatter.string(from: date)
    }
    
    //could also send the function the format I want to use
    public func returnPredictionCreatedTimeText() -> String? {
        // returns a string of the prediction time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        if let tc = self.timecreated {
            let date = Date(timeIntervalSince1970: tc)
            return formatter.string(from: date)
        }else{
            return nil
        }
    }
    
    //could also send the function the format I want to use
    public func returnPredictionCreatedDateText() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        if let tc = self.timecreated {
            let date = Date(timeIntervalSince1970: tc)
            return formatter.string(from: date)
        }else{
            return nil
        }
    }
    
    public func returnPredictionCreatedDateTimeText() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d h:mm:ss a"
        if let tc = self.timecreated {
            let date = Date(timeIntervalSince1970: tc)
            return formatter.string(from: date)
        }else{
            return nil
        }
    }
    
    public func returnRredictionMoodText() -> String {
        return "\(String(describing: self.mood))"
    }
    
    public func returnRredictionMoodString() -> String {
        if let text = Prediction.MoodStrings[self.returnRredictionMoodText()]{
            return text
        }else{
            return "no string"
        }
    }
    
    public func returnRredictionGSRText() -> String {
        if let state = self.gsreval{
            return "\(state)"
        }else{
            return ""
        }
    }
    
    public func returnRredictionGSRString() -> String {
        if let text = Prediction.GSRStrings[self.returnRredictionGSRText()]{
            return text
        }else{
            return "no string"
        }
    }

    
    public func returnPredictionConfirmedText() -> String {
        var text = ""
        if self.confirmed != nil {
            text = "\(String(describing: self.confirmed))"
        } else {
            text = "not confirmed"
        }
        return text
    }
    
    //theoretically I don't need this now
    public func returnDataPoint(data:[PhysData]) -> PhysData? {
        //I could also save the source data in the prediction ....
        let resultData = data.filter{$0.time == self.time}
        if resultData.count > 1 {
            print("have more than one matching data point")
        }else if resultData.count == 0{
            print("have no matching data points")
        }
        return resultData.first
    }
    
    //I will be swapping this out with a thing for sending to FB
    //MARK: NSCoding
    //so I am encoding an array of predictions so it should be here that I fix this
    //and I think I need to put it on dataPoint, because presumably it like calls this function for that
    func encode(with aCoder: NSCoder) {
        debugPrint("encodeCoder")
        aCoder.encode(self.timecreated, forKey: PropertyKey.timecreated)
        aCoder.encode("\(self.mood)", forKey: PropertyKey.mood)
        aCoder.encode(self.confirmed, forKey: PropertyKey.confirmed)
        aCoder.encode(self.note, forKey: PropertyKey.note)
        print(self.time)
        aCoder.encode(self.time, forKey: PropertyKey.time)
        aCoder.encode(self.millis, forKey: PropertyKey.millis)
        aCoder.encode(self.gsr, forKey: PropertyKey.gsr)
        if let gsreval = self.gsreval {
            aCoder.encode("\(gsreval)", forKey: PropertyKey.gsreval)
        }
        aCoder.encode(self.bpm, forKey: PropertyKey.bpm)
        aCoder.encode(self.temp, forKey: PropertyKey.temp)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The mood is required. If we cannot decode a mood string, the initializer should fail.
        guard let moodb = aDecoder.decodeObject(forKey: PropertyKey.mood) as? String else{
            os_log("Unable to decode the mood string for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let mood = Prediction.moods(rawValue: moodb) else {
                os_log("Unable to decode the mood for a Prediction object.", log: OSLog.default, type: .debug)
                return nil
        }
        let gsreval2: PhysData.gsrstate?
        
        if let gsrevalb = aDecoder.decodeObject(forKey: PropertyKey.gsreval) as? String {
            gsreval2 = PhysData.gsrstate(rawValue: gsrevalb)
        }else {
            print("in else")
            gsreval2 = PhysData.gsrstate.none
        }
        
        
        let t2 = aDecoder.decodeDouble(forKey: PropertyKey.time)
        print("t2: \(t2)")
        guard let time = aDecoder.decodeDouble(forKey: PropertyKey.time) as? TimeInterval else{
            os_log("Unable to decode the time for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let millis = aDecoder.decodeDouble(forKey: PropertyKey.millis) as? Double else{
            os_log("Unable to decode the millis for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let gsr = aDecoder.decodeObject(forKey: PropertyKey.gsr) as? Float else{
            os_log("Unable to decode the gsr for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        let gsr2 = CGFloat(gsr)
        
        guard let bpm = aDecoder.decodeInteger(forKey: PropertyKey.bpm) as? Int else{
            os_log("Unable to decode the bpm for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let temp = aDecoder.decodeDouble(forKey: PropertyKey.temp) as? Double else{
            os_log("Unable to decode the temp for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let timecreated = aDecoder.decodeObject(forKey: PropertyKey.timecreated) as? Double
        let confirmed = aDecoder.decodeObject(forKey: PropertyKey.confirmed) as? Bool
        let note = aDecoder.decodeObject(forKey: PropertyKey.note) as? String
       
        
        // Must call designated initializer.
        self.init(timecreated: timecreated, mood: mood, confirmed: confirmed, note: note, time: time, millis: millis, gsr: gsr2, gsreval: gsreval2, bpm: bpm, temp:temp)
        
    }
}
