//
//  PredictionViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-26.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit
import os.log

class PredictionViewController: UIViewController, DataProtocolClient, UITextViewDelegate {
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    //MARK: Properties
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var confirmationIcon: UIImageView!
    @IBOutlet weak var confirmationText: UILabel!
    @IBOutlet weak var bpmValueLabel: UILabel!
    @IBOutlet weak var gsrValueLabel: UILabel!
    @IBOutlet weak var tempValueLabel: UILabel!
    //Maybe I should make the notes just a sub-item of predictions??? Could still display a list of them I think.
    //how do I send it and send it back? Like send both to it?
    @IBOutlet weak var notesField: UITextView!
    
    @IBOutlet weak var predictionSaveButton: UIButton!
    
    /*
     This value is either passed by `PredictionTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new prediction.
     */
    var prediction: Prediction?
    var orginnote = "" // will probably be a string really
    //var dataPoint: PhysData?
    //var bpmValue: Int?
    //var gsrValue: CGFloat?
    //Need to figure out why the gsrstate isn't OK here.
    //var gsreval: gsrstate? // maybe make this an iterable
    //var tempValue: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views if editing an existing Prediction.
        // find these on the other code and maybe give them a function? On the prediction itself?
        if let prediction = prediction {
            
            dateTimeLabel.text = prediction.returnPredictionDateTimeText()
            moodLabel.text = prediction.returnRredictionMoodText()
            // need to convert to text
            confirmationText.text = prediction.returnPredictionConfirmedText()
            // need to send this to the prediction when I make it, or get it from the associated data
            //which I should be able to do now pretty simply.
            //oh I need to pass it the data point too
            bpmValueLabel.text = "\(prediction.bpm)"
            gsrValueLabel.text = "\(prediction.gsr)"
            tempValueLabel.text =  "\(prediction.temp) °C"
            
            // need to decide how I'm implementing the notes and then get the associated note field or whatever
            if let note = prediction.note {
                orginnote = note // change this based on how I actually set the note
            }
            
            notesField.text = prediction.note
        
        }
        
        notesField.delegate = self
        // Enable the Save button only if the notes field has some text in it and has been edited.
        updateSaveButtonState()

        // Do any additional setup after loading the view.
    }
    
    //MARK: UITextViewDelegate
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        // Hide the keyboard.
        textView.resignFirstResponder()
        print("should return text field")
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
    
    //this is kinda ridiculous but works.
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
        //If I rework this with a navigation bar
        //navigationItem.title = textField.text
        if let prediction = prediction {
            prediction.note = textView.text
        }
    }
    
    private func textViewShouldEndEditing(_ textView: UITextView) {
        print("text view should end text field")
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = notesField.text ?? ""
        predictionSaveButton.isEnabled = !(text.isEmpty || text == orginnote)
    }

    // MARK: - Navigation
    
    // This method lets you configure a view controller before it's presented.
    //send the prediction back. Also all I can edit is the note itself.  I really think I should make the

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        //saved this for if I put it into a UI Bar to make it easier to make adaptable
        //guard let button = sender as? UIBarButtonItem, button === saveButton else {
        guard let button = sender as? UIButton, button === predictionSaveButton else {
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
    @IBAction func closePredictionView(_ sender: Any) {
             dismiss(animated: true, completion: nil)
    }
}
