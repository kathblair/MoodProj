//
//  NotesTableViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//

import UIKit
import os.log

class NotesTableViewController: UITableViewController, DataProtocolClient {
    //MARK: Properties
    var notes = [Prediction]()
    var predictions: [Prediction]?
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(notes)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let dataStack = dataStack, let preds = dataStack.predictions {
            // but these are just the sample predictions, not the one we theoretically added on the first screen .. oh maybe we didn't.
            //print(notes[0].noteTimeReferenced)
            //now I gotta figure out how to get all the ones with notes
            //maybe I will match it up when I return to this screen
            predictions = preds
            let withNotes = preds.filter {
                $0.note != nil || $0.note != ""
            }
            notes = withNotes
            //going to have to update predictions at the end
        }
        print(notes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "NotesTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotesTableViewCell  else {
            fatalError("The dequeued cell is not an instance of NotesTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let note = notes[indexPath.row]

        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "h:mm a"
        let formatterrange = DateFormatter()
        formatterrange.dateFormat = "M/d h:mm a"
        if let tc = note.timecreated {
            let createddate = Date(timeIntervalSince1970: tc)
            cell.noteDateLabel.text = formatter.string(from: createddate)
            cell.noteTimeLabel.text = timeformatter.string(from: createddate)
        }
        
        let refdate = Date(timeIntervalSince1970: note.time)
        let rangetext = formatterrange.string(from: refdate)
        //the location of all of this is messed up
        
        cell.noteContextRangeLabel.text  = rangetext
        cell.noteTextContainer.text = note.note
        
        // need to add start and end of context if I go that route of having that

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
            os_log("Adding a new note.", log: OSLog.default, type: .debug)
            
        case "ShowNotesDetail":
            guard let ShowNoteDetail = segue.destination as? NoteViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedNoteCell = sender as? NotesTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "default value")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedNoteCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedNote = notes[indexPath.row]
            ShowNoteDetail.note = selectedNote
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
    }
    
    //MARK: Actions
    //this RECIEVES data from the previousl one
    @IBAction func unwindToNoteList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NoteViewController, let note = sourceViewController.note {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing prediction
                notes[selectedIndexPath.row] = note
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new prediction. Not a case that actually happens
                let newIndexPath = IndexPath(row: notes.count, section: 0)
                notes.append(note)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            //save the predictions ...
            for note in notes {
                //print(note.note)
                //find the appropriate predictions .. could match by more than one thing
                if let predictions = predictions {
                    for var p in predictions {
                        if(p.time == note.time && p.timecreated == note.timecreated){
                            p=note
                        }
                    }
                }
            }
            if let predictions = predictions{
                dataStack?.savePredictions(predictions: predictions)
            }
        }
    }
    
    //MARK: Private Methods

}
