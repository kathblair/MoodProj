//
//  NoteViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-26.
//

import UIKit
import os.log

class NoteViewController: UIViewController, DataProtocolClient, UITextViewDelegate {
    //MARK: Properties
    @IBOutlet weak var noteDateTimeLabel: UILabel!
    @IBOutlet weak var noteContextTitle: UILabel!
    @IBOutlet weak var noteContextRange: UILabel!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var noteCancelButton: UIButton! //why is this unlinked?
    @IBOutlet weak var noteSaveButton: UIButton!
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    /*
     This value is either passed by `NoteTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new note.
     */
    var note: Prediction?
    var orginnote = "" // will probably be a string really
    
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
            noteDateTimeLabel.text = note.returnPredictionCreatedDateTimeText()
            noteContextTitle.text = "Context Title - Not a Thing"
            // need to convert to text
            noteContextRange.text = note.returnPredictionDateTimeText()
            // need to figure out whether the note is its own thing or a field for the prediction
            if let nn = note.note {
                orginnote = nn // change this based on how I actually set the note
            }
            noteText.text = note.note
        }

         noteText.delegate = self
        // Enable the Save button only if the notes field has some text in it and has been edited.
        updateSaveButtonState()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: UITextViewDelegate
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        // Hide the keyboard.
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Disable the Save button while editing.
        //predictionSaveButton.isEnabled = false
        //oooops I can't resign editing
        //print("started editing text field")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        //updateSaveButtonState()
        //If I rework this with a navigation bar
        //navigationItem.title = textField.text
        //print("ended editing text field")
    }
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
        //If I rework this with a navigation bar
        //navigationItem.title = textField.text
        if let note = note {
            note.note = textView.text
        }
        //print("text view changed text field")
    }
    
    private func textViewShouldEndEditing(_ textView: UITextView) {
        //print("text view should end text field")
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = noteText.text ?? ""
        noteSaveButton.isEnabled = !(text.isEmpty || text == orginnote)
    }

    
    // MARK: - Navigation
    
    // This method lets you configure a view controller before it's presented.
    //send the prediction back. Also all I can edit is the note itself.  I really think I should make the
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === noteSaveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        //since I am only editing existing predictions, I can just do this
        let n = note       
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        note = n // is there really any point in doing this, it seems redundant
        
    }
    
    
    //MARK: Actions
    @IBAction func closeNoteView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
