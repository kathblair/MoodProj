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


class DataStack {
    //MARK: Properties
    
    var data: [PhysData]?
    var predictions: [Prediction]?
    var notes: [Note]?
    var baseline:[String:Float] = ["bpm":0, "gsr":0, "temp":0]
    
    //for saving the predictions with notes
    static let PredictionsDocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let PredictionsArchiveURL = PredictionsDocumentsDirectory.appendingPathComponent("predictions")
    
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
    
    //Mark: Saving and loading
    //Save predictions to file, should update with Firebase --> called when I change the prediction notes, make new predictions, and also if the app resigns or is terminated
    public func savePredictions(predictions:[Prediction]) {
         let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(predictions, toFile: DataStack.PredictionsArchiveURL.path)
         if isSuccessfulSave {
         os_log("Predictions successfully saved.", log: OSLog.default, type: .debug)
         } else {
         os_log("Failed to save predictions...", log: OSLog.default, type: .error)
         }
    }
    
    //Load predictions --> called from the appdelegate. Will also need to update this with FB data stuff
    public func loadPredictions() -> [Prediction]? {
        print("trying to load predictions")
        return NSKeyedUnarchiver.unarchiveObject(withFile: DataStack.PredictionsArchiveURL.path) as? [Prediction]
    }
    
}
