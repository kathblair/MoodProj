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


class Prediction: NSObject, NSCoding{
    
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
        static let dataPoint = "dataPoint"
    }

    
    //MARK: Properties
    
    //var timeofprediction: TimeInterval
    var timecreated: TimeInterval?
    var mood: moods //probably need one for a corrected mood too
    var confirmed: Bool? // if it's not set, it wasn't evaluated.
    var note: String?
    var dataPoint: PhysData
    
    //MARK: Archiving Paths -- probably not NOT need this, will save to Firebase instead
    

    
    //MARK: Initialization
    
    //init?(timeofprediction: TimeInterval, timecreated: TimeInterval?, mood: moods, confirmed: Bool?, note: String?) {
    init?(timecreated: TimeInterval?, mood: moods, confirmed: Bool?, note: String?, dataPoint: PhysData) {
        self.timecreated = timecreated
        self.mood = mood
        self.confirmed = confirmed
        self.note = note
        self.dataPoint = dataPoint
        
        // Initialization should fail if there is no name or if the rating is negative.
        // The name must not be empty
        /*
        guard !(timeofprediction==nil) else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard !(mood==nil) else {
            return nil
        }
        */
    }
    
    //could also send the function the format I want to use
    public func returnPredictionTimeText() -> String {
        // returns a string of the prediction time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Date(timeIntervalSince1970: self.dataPoint.time)
        return formatter.string(from: date)
    }
    
    //could also send the function the format I want to use
    public func returnPredictionDateText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let date = Date(timeIntervalSince1970: self.dataPoint.time)
        return formatter.string(from: date)
    }
    
    public func returnPredictionDateTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d h:mm a"
        let date = Date(timeIntervalSince1970: self.dataPoint.time)
        return formatter.string(from: date)
    }
    
    public func returnRredictionMoodText() -> String {
        return "\(String(describing: self.mood))"
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
        let resultData = data.filter{$0.time == self.dataPoint.time}
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
        aCoder.encode(self.timecreated, forKey: PropertyKey.timecreated)
        aCoder.encode("\(self.mood)", forKey: PropertyKey.mood)
        aCoder.encode(self.confirmed, forKey: PropertyKey.confirmed)
        aCoder.encode(self.note, forKey: PropertyKey.note)
        print("about to encode a data point")
        aCoder.encode(self.dataPoint, forKey: PropertyKey.dataPoint) //mildly scared of this
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The mood is required. If we cannot decode a name string, the initializer should fail.
        guard let moodb = aDecoder.decodeObject(forKey: PropertyKey.mood) as? String else{
            os_log("Unable to decode the mood string for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let mood = Prediction.moods(rawValue: moodb) else {
                os_log("Unable to decode the mood for a Prediction object.", log: OSLog.default, type: .debug)
                return nil
        }
        
        //the data point is required.
        let dp2 = aDecoder.decodeObject(forKey: PropertyKey.dataPoint)
        let t2 = aDecoder.decodeObject(forKey: PropertyKey.timecreated)
        print("String to decode: \(dp2)")
        guard let dataPoint = aDecoder.decodeObject(forKey: PropertyKey.dataPoint) as? PhysData else {
            os_log("Unable to decode the dataPoint for a Prediction object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let timecreated = aDecoder.decodeObject(forKey: PropertyKey.timecreated) as? Double
        let confirmed = aDecoder.decodeObject(forKey: PropertyKey.confirmed) as? Bool
        let note = aDecoder.decodeObject(forKey: PropertyKey.note) as? String
       
        
        // Must call designated initializer.
        self.init(timecreated: timecreated, mood: mood, confirmed:confirmed, note:note, dataPoint: dataPoint)
        
    }
}
