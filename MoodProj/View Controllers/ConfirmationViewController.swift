//
//  ConfirmationViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-27.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit
import os.log

class ConfirmationViewController: UIViewController, DataProtocolClient, UITextViewDelegate {

    //may want to do this stuff in the mail view controller
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    var prediction: Prediction?
    var orginnote = ""
    @IBOutlet weak var confirmationInstructionText: UILabel!
    @IBOutlet weak var confirmationNotesView: UITextView!
    @IBOutlet weak var confirmationSaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up views if editing an existing Prediction.
        // find these on the other code and maybe give them a function? On the prediction itself?
        if let prediction = prediction {
            
            //this is the confirmation screen, so set the confirmation flag.
            
            prediction.confirmed = true
            prediction.originalmood = prediction.mood
            
            if let originalText = confirmationInstructionText.text {
                print("have originaltext")
                let range = NSRange(location: 0, length: originalText.utf16.count)
                let regex = try! NSRegularExpression(pattern: "\\[\\[mood\\]\\]")
                let moodtext = prediction.returnRredictionMoodText()
                let newtext = regex.stringByReplacingMatches(in: originalText, options: [], range: range, withTemplate: moodtext)
                confirmationInstructionText.text = newtext
            }

            if let note = prediction.note {
                orginnote = note // change this based on how I actually set the note
            }
            confirmationNotesView.text = prediction.note
        }
        
        confirmationNotesView.delegate = self
        // Enable the Save button only if the notes field has some text in it and has been edited.
        updateSaveButtonState()
        
        // Do any additional setup after loading the view.

        // Do any additional setup after loading the view.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
        //If I rework this with a navigation bar
        //navigationItem.title = textField.text
        if let prediction = prediction {
            prediction.note = textView.text
        }
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = confirmationNotesView.text ?? ""
        confirmationSaveButton.isEnabled = !(text.isEmpty || text == orginnote)
    }

    // MARK: - Navigation
    // This method lets you configure a view controller before it's presented.
    //send the prediction back. Also all I can edit is the note itself.  I really think I should make the
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        //saved this for if I put it into a UI Bar to make it easier to make adaptable
        //guard let button = sender as? UIBarButtonItem, button === saveButton else {
        guard let button = sender as? UIButton, button === confirmationSaveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let pred = prediction
        //print(pred?.note)
        // also there's only the original prediction that you would send back ...
        
        //pred.notes = notes
        // Set the prediction to be passed to PredictionTableViewController after the unwind segue.
        prediction = pred
        //meal = Meal(name: name, photo: photo, rating: rating)
    }
    
    //MARK: - Actions
    @IBAction func dismissConfirmation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        // use completion to do the animation on saved?
    }
    
}
