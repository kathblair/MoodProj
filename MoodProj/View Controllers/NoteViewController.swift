//
//  NoteViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-26.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, DataProtocolClient {
    //MARK: Properties
    @IBOutlet weak var noteDateTimeLabel: UILabel!
    @IBOutlet weak var noteContextTitle: UILabel!
    @IBOutlet weak var noteContextRange: UILabel!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var noteSaveButton: UIButton!
    @IBOutlet weak var noteCancelButton: UIButton!
    
    
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    /*
     This value is either passed by `NoteTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new note.
     */
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*
         // Implement this for the note content
         // Handle the text field’s user input through delegate callbacks.
         nameTextField.delegate = self
         
         // Enable the Save button only if the text field has a valid Meal name.
         updateSaveButtonState()
         */
        
        // Set up views if editing an existing Prediction.
        // find these on the other code and maybe give them a function? On the prediction itself?
        if let note = note {
            noteDateTimeLabel.text = note.returnNoteCreatedDateTimeText()
            noteContextTitle.text = note.returnNoteContextTitle()
            // need to convert to text
            noteContextRange.text = note.returnNoteRangeText()
            // need to figure out whether the note is its own thing or a field for the prediction
            noteText.text = note.text
        }
        //I should probably do something to enable / disable save
        //updateSaveButtonState()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Actions
    @IBAction func closeNoteView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
