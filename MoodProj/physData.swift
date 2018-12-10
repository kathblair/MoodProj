//
//  Prediction.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation
import UIKit


class PhysData {
    
    enum gsrstate:CaseIterable {
        case sf // small and few
        case sm // small and many
        case bs // big and some
        case bo // big and one
    }
    
    
    //MARK: Properties
    
    var millis: Double
    var time: TimeInterval
    var gsr: CGFloat
    var gsreval: gsrstate? // maybe make this an iterable
    var bpm: Int
    var temp: Double
    
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
}
