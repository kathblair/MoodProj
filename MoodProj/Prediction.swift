//
//  Prediction.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation
import UIKit


class Prediction {
    
    enum moods:CaseIterable {
        case happy
        case sad
        case angry
        case pain
        case unknown
    }

    
    //MARK: Properties
    
    //var timeofprediction: TimeInterval
    var timecreated: TimeInterval?
    var mood: moods
    var confirmed: Bool? // if it's not set, it wasn't evaluated.
    var note: String?
    var dataPoint: PhysData
    
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
    
}
