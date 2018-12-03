//
//  Note.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation
import UIKit


class Note {
    
    enum contexts:CaseIterable {
        case predictions
        case timeline
    }
    
    
    //MARK: Properties
    
    var noteTimeCreated: TimeInterval
    // add this to connect to the predictions
    var noteTimeReferenced: TimeInterval?
    //probably change this to just be the time reference and just do it that way
    var noteContext: contexts?
    var noteContextStart: TimeInterval?
    var noteContextEnd: TimeInterval?
    var text: String // make sure they can't save it if it's empty
    
    //MARK: Initialization
    
    init?(noteTimeCreated: TimeInterval, noteTimeReferenced: TimeInterval?, noteContext: contexts?, noteContextStart: TimeInterval?, noteContextEnd: TimeInterval?, text: String) {
        self.noteTimeCreated = noteTimeCreated
        self.noteTimeReferenced = noteTimeReferenced
        self.noteContext = noteContext
        self.noteContextStart = noteContextStart
        self.noteContextEnd = noteContextEnd
        self.text = text
        
        // Initialization should fail if there is no text.
        // The name must not be empty
        guard !(text==nil) else {
            return nil
        }
        
        guard !(noteTimeCreated==nil) else {
            return nil
        }
        
    }
    
    //could also send the function the format I want to use
    public func returnNoteCreatedTimeText() -> String {
        // returns a string of the prediction time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Date(timeIntervalSince1970: self.noteTimeCreated)
        return formatter.string(from: date)
    }
    
    //could also send the function the format I want to use
    public func returnNoteCreatedDateText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let date = Date(timeIntervalSince1970: self.noteTimeCreated)
        return formatter.string(from: date)
    }
    
    public func returnNoteCreatedDateTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d h:mm a"
        let date = Date(timeIntervalSince1970: self.noteTimeCreated)
        return formatter.string(from: date)
    }
    
    //could also send the function the format I want to use
    public func returnNoteReferencedTimeText() -> String {
        // returns a string of the prediction time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Date(timeIntervalSince1970: self.noteTimeReferenced ?? 0)
        return formatter.string(from: date)
    }
    
    //could also send the function the format I want to use
    public func returnNoteReferencedDateText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let date = Date(timeIntervalSince1970: self.noteTimeReferenced ?? 0)
        return formatter.string(from: date)
    }
    
    public func returnNoteReferencedDateTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d h:mm a"
        let date = Date(timeIntervalSince1970: self.noteTimeReferenced ?? 0)
        return formatter.string(from: date)
    }
    
    public func returnNoteRangeText() -> String {
        let formatterrange = DateFormatter()
        formatterrange.dateFormat = "M/d h:mm a"
        let rangestart = Date(timeIntervalSince1970: self.noteContextStart ?? 0) // this is going to be stupid if I don't have it and I should take it out
        let rangeend = Date(timeIntervalSince1970: self.noteContextEnd ?? 0) // this is going to be stupid if I don't have it and I should take it out
        let rangetext = formatterrange.string(from: rangestart) + " to " + formatterrange.string(from: rangeend)
        return rangetext
    }
    
    
    public func returnNoteContextTitle() -> String {
        var text = ""
        if let nC = self.noteContext {
            text = "\(nC)"
        } else {
            text = "Unable to retrieve context title."
        }
        return text
    }
    
}

