//
//  PredictionsTableViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-20.
//

import UIKit
import os.log

class PredictionsTableViewController: UITableViewController, DataProtocolClient {
    //MARK: Properties
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    var predictions = [Prediction]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dataStack = dataStack, let preds = dataStack.predictions {
            predictions = preds.sorted(by: { $0.time > $1.time }) 
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
        timeformatter.dateFormat = "h:mm:ss a"
        let date = Date(timeIntervalSince1970: prediction.time)
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
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear()
        tableView.reloadData()
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
    //this SENDS data to the next one
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
    
    //MARK: Actions
    //this RECIEVES data from the previous one
    @IBAction func unwindToPredictionList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? PredictionViewController, let prediction = sourceViewController.prediction {            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing prediction
                predictions[selectedIndexPath.row] = prediction
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new prediction. I will actually never be doing this, but whatever
                let newIndexPath = IndexPath(row: predictions.count, section: 0)
                predictions.append(prediction)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            //save the predictions ... can be done on any prediction, it will save all of them ... should I do it on the data stack instead?
            dataStack?.savePredictions(predictions: predictions)
        }
    }
 
    
    //MARK: Private Methods

}
