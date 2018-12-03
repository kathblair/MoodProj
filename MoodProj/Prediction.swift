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
    }

    
    //MARK: Properties
    
    var timeofprediction: TimeInterval
    var timecreated: TimeInterval?
    var mood: moods
    var confirmed: Bool? // if it's not set, it wasn't evaluated.
    
    //MARK: Initialization
    
    init?(timeofprediction: TimeInterval, timecreated: TimeInterval?, mood: moods, confirmed: Bool?) {
        self.timeofprediction = timeofprediction
        self.timecreated = timecreated
        self.mood = mood
        self.confirmed = confirmed
        
        // Initialization should fail if there is no name or if the rating is negative.
        // The name must not be empty
        guard !(timeofprediction==nil) else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard !(mood==nil) else {
            return nil
        }
    }
    
    //could also send the function the format I want to use
    public func returnPredictionTimeText() -> String {
        // returns a string of the prediction time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Date(timeIntervalSince1970: self.timeofprediction)
        return formatter.string(from: date)
    }
    
    //could also send the function the format I want to use
    public func returnPredictionDateText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let date = Date(timeIntervalSince1970: self.timeofprediction)
        return formatter.string(from: date)
    }
    
    public func returnPredictionDateTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d h:mm a"
        let date = Date(timeIntervalSince1970: self.timeofprediction)
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
    
}
