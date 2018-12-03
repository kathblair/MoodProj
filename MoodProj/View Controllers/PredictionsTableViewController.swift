//
//  PredictionsTableViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-20.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit
import os.log

class PredictionsTableViewController: UITableViewController {
    //MARK: Properties
    var predictions = [Prediction]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadSamplePredictions()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // use this for more columns?
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PredictionsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PredictionsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PredictionsTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let prediction = predictions[indexPath.row]
        
        //put this into functions in the Predictions data structure
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "h:mm a"
        let date = Date(timeIntervalSince1970: prediction.timeofprediction)
        //the location of all of this is messed up
        cell.dateLabel.text = formatter.string(from: date)
        cell.timeLabel.text = timeformatter.string(from: date)
        cell.moodLabel.text = "\(String(describing: prediction.mood))"
        
        if(prediction.confirmed != nil){
            cell.confirmationLabel.text = "\(String(describing: prediction.confirmed!))"
        }else{
            cell.confirmationLabel.text = "not confirmed"
        }

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            //this is not really actually a thing. should delete
            os_log("Adding a new prediction.", log: OSLog.default, type: .debug)
            
        case "ShowPredictionDetail":
            guard let ShowPredictionDetail = segue.destination as? PredictionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPredictionCell = sender as? PredictionsTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "default value")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPredictionCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPrediction = predictions[indexPath.row]
            ShowPredictionDetail.prediction = selectedPrediction
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
    }
 
    
    //MARK: Private Methods
    
    private func loadSamplePredictions() {
        // make one to load from the DB ... and one to save from a set of data to a prediction.
        guard let prediction1 = Prediction(timeofprediction: NSDate().timeIntervalSince1970, timecreated: NSDate().timeIntervalSince1970, mood: Prediction.moods.happy, confirmed: true) else {
            fatalError("Unable to instantiate prediction1")
        }
        guard let prediction2 = Prediction(timeofprediction: NSDate().timeIntervalSince1970, timecreated: NSDate().timeIntervalSince1970, mood: Prediction.moods.sad, confirmed: false) else {
            fatalError("Unable to instantiate prediction2")
        }
        
        guard let prediction3 = Prediction(timeofprediction: NSDate().timeIntervalSince1970, timecreated: NSDate().timeIntervalSince1970, mood: Prediction.moods.angry, confirmed: nil) else {
            fatalError("Unable to instantiate prediction3")
        }
        
        predictions += [prediction1, prediction2, prediction3]
    }

}
