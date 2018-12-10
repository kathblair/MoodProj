//
//  Prediction.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation
import UIKit


class DataStack {
    //MARK: Properties
    
    var data: [PhysData]?
    var predictions: [Prediction]?
    var notes: [Note]?
    var baseline:[String:Float] = ["bpm":0, "gsr":0, "temp":0]
    
    //oh and then I could build the others then too and put them in their relevant view controllers
    
    //MARK: Initialization
    
    init?(data: [PhysData]?, predictions: [Prediction]?, notes:[Note]?) {
        self.data = data
        //maybe I could get the baseline values here? would calulate once each time it was run
        if let data = data {
            var bpmavg = 0
            var tempavg = 0
            var gsravg = 0
            let cutoff = data[0].time - 10
            let last10seconds = data.filter {
                $0.time > cutoff
            }
            for item in last10seconds {
                bpmavg += Int(item.bpm)
                tempavg += Int(item.temp)
                gsravg += Int(item.gsr)
            }
            let bpma = Float(bpmavg/last10seconds.count)
            let tempa = Float(tempavg/last10seconds.count)
            let gsra = Float(gsravg/last10seconds.count)
            self.baseline = ["bpm":bpma, "gsr":gsra, "temp":tempa]
        }
        self.predictions = predictions // where I'm saving the predictions for the whole schlomozzle
        self.notes = notes
    }
    
}
