//
//  CorrectionViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-27.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit
import os.log

class CorrectionViewController: UIViewController, DataProtocolClient, UITextViewDelegate {
    
    // or do I want to make the opening view controller do that?
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    var prediction: Prediction?
    var originnote = ""
    var originmood: Prediction.moods?
    var indexes:[String: Int] = [:]

    @IBOutlet weak var correctionInstructionText: UILabel!
    @IBOutlet weak var correctionMoodPicker: UISegmentedControl!
    @IBOutlet weak var correctionNotesView: UITextView!
    @IBOutlet weak var correctionSaveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up views if editing an existing Prediction.
        // find these on the other code and maybe give them a function? On the prediction itself?
        if let prediction = prediction {
            if let note = prediction.note {
               originnote = note
            }
            
            
            //this is the correction screen, so set the confirmation flag.
            
            //set up the segmented control
            correctionMoodPicker.removeAllSegments()
            var i = 0
            for moodstring in Prediction.MoodStrings {
correctionMoodPicker.insertSegment(withTitle: moodstring.value, at: i, animated: false)
                indexes[moodstring.key]=i
                i = i+1
                }
            
            //select the correct one for the current mood
            let mstr = prediction.returnRredictionMoodText()
           
            if let index = indexes[mstr] { correctionMoodPicker.selectedSegmentIndex = index
            }
            
            if let note = prediction.note {
                originnote = note // change this based on how I actually set the note
            }
            correctionNotesView.text = prediction.note
        }
        
        correctionNotesView.delegate = self
        // Enable the Save button only if the notes field has some text in it and has been edited.
        updateSaveButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
        //If I rework this with a navigation bar
        //navigationItem.title = textField.text
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = correctionNotesView.text ?? ""
        correctionSaveButton.isEnabled = !(text.isEmpty || text == originnote)
        //add checking if one of the moods is selected. Actually no don't, if you just click the save button and nothing else, then you have actually CONFIRMED the prediction.
    }

    
    // MARK: - Navigation

 // This method lets you configure a view controller before it's presented.
 //send the prediction back. Also all I can edit is the note itself.  I really think I should make the
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //just set these things when you're going to send it back
        if let prediction = prediction {
            prediction.confirmed = false
            prediction.originalmood = prediction.mood
                let selectedi = correctionMoodPicker.selectedSegmentIndex
            let iis = (indexes as NSDictionary).allKeys(for: selectedi) as! [String]
            print(iis.count)
            let newmood = Prediction.moods(rawValue: iis[0])
            if let newmood = newmood, prediction.mood != newmood {
                //the user changed the mood
                prediction.originalmood = prediction.mood
                prediction.mood = newmood
                prediction.confirmed = false
            }else if let newmood = newmood {
                //the user didn't change the mood, but they are saving
                prediction.originalmood = prediction.mood
                prediction.mood = newmood
                prediction.confirmed = true
            }
            if correctionNotesView.text != originnote {
                    //note's changed, set the actual note
                    prediction.note = correctionNotesView.text
            }
        }
        // Configure the destination view controller only when the save button is pressed.
        //saved this for if I put it into a UI Bar to make it easier to make adaptable
        //guard let button = sender as? UIBarButtonItem, button === saveButton else {
        guard let button = sender as? UIButton, button === correctionSaveButton else {
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
    
    //MARK: Actions
    
    @IBAction func dismissCorrection(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setNewMood(_ sender: Any) {
    }
    

}
