//
//  PredictionViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-26.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class PredictionViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var confirmationIcon: UIImageView!
    @IBOutlet weak var confirmationText: UILabel!
    @IBOutlet weak var bpmValueLabel: UILabel!
    @IBOutlet weak var gsrValueLabel: UILabel!
    @IBOutlet weak var tempValueLabel: UILabel!
    //Maybe I should make the notes just a sub-item of predictions??? Could still display a list of them I think.
    @IBOutlet weak var notesField: UITextView!
    
    /*
     This value is either passed by `PredictionTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new prediction.
     */
    var prediction: Prediction?
    
    
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
        if let prediction = prediction {
            dateTimeLabel.text = prediction.returnPredictionDateTimeText()
            moodLabel.text = prediction.returnRredictionMoodText()
            // need to convert to text
            confirmationText.text = prediction.returnPredictionConfirmedText()
            // need to send this to the prediction when I make it, or get it from the associated data
            bpmValueLabel.text = "Not Implemented"
            gsrValueLabel.text =  "Not Implemented"
            tempValueLabel.text =  "Not Implemented"
            
            // need to decide how I'm implementing the notes and then get the associated note field or whatever
            notesField.text = "Not Implemented Note Text Yet -- Need to Associate With Prediction"
        }

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
    
    //MARK: - Actions
    @IBAction func closePredictionView(_ sender: Any) {
             dismiss(animated: true, completion: nil)
    }
}
