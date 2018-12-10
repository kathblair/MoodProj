//
//  NotesTableViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit
import os.log

class NotesTableViewController: UITableViewController, DataProtocolClient {
    //MARK: Properties
    var notes = [Note]()
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(notes)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let dataStack = dataStack, let ns = dataStack.notes {
            notes = ns
            print("have dataStack")
            // but these are just the sample predictions, not the one we theoretically added on the first screen .. oh maybe we didn't.
            print(notes[0].noteTimeReferenced)
            
        }else{
            
        }
        print(notes)
        //loadSampleNotes()
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
        let createddate = Date(timeIntervalSince1970: note.noteTimeCreated)
        let rangestart = Date(timeIntervalSince1970: note.noteContextStart ?? 0) // this is going to be stupid if I don't have it and I should take it out
        let rangeend = Date(timeIntervalSince1970: note.noteContextEnd ?? 0) // this is going to be stupid if I don't have it and I should take it out
        let rangetext = formatterrange.string(from: rangestart) + " to " + formatterrange.string(from: rangeend)
        //the location of all of this is messed up
        cell.noteDateLabel.text = formatter.string(from: createddate)
        cell.noteTimeLabel.text = timeformatter.string(from: createddate)
        if let nC = note.noteContext {
            cell.noteContextTitleLabel.text = "\(nC)"
        } else {
            print("Unable to retrieve context title.")
        }
        //cell.noteContextTitleLabel.text = "\(String(describing: note.noteContext))"
        cell.noteContextRangeLabel.text  = rangetext
        cell.noteTextContainer.text = note.text
        
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
            os_log("Adding a new prediction.", log: OSLog.default, type: .debug)
            
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
    
    //MARK: Private Methods
    //moving this to appdelegate.
    private func loadSampleNotes() {
        // make one to load from the DB ... and something to save added notes.
        
        
        guard let note1 = Note(noteTimeCreated: NSDate().timeIntervalSince1970, noteTimeReferenced: NSDate().timeIntervalSince1970, noteContext: Note.contexts.timeline, noteContextStart: NSDate().timeIntervalSince1970, noteContextEnd:NSDate().timeIntervalSince1970, text: "this is a note about a thing that is happening with my mood.") else {
            fatalError("Unable to instantiate note1")
        }
        guard let note2 = Note(noteTimeCreated: NSDate().timeIntervalSince1970, noteTimeReferenced: NSDate().timeIntervalSince1970, noteContext: Note.contexts.predictions, noteContextStart: NSDate().timeIntervalSince1970, noteContextEnd:NSDate().timeIntervalSince1970, text: "this is a second note about a thing that is happening with my mood.") else {
            fatalError("Unable to instantiate note2")
        }
        
        guard let note3 = Note(noteTimeCreated: NSDate().timeIntervalSince1970, noteTimeReferenced: NSDate().timeIntervalSince1970, noteContext: Note.contexts.timeline, noteContextStart: NSDate().timeIntervalSince1970, noteContextEnd:NSDate().timeIntervalSince1970, text: "this is a third note about a thing that is happening with my mood.") else {
            fatalError("Unable to instantiate note3")
        }
        
        notes += [note1, note2, note3]
    }

}
