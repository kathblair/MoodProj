//
//  CorrectionViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-27.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class CorrectionViewController: UIViewController, DataProtocolClient {
    
    
    // or do I want to make the opening view controller do that?
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func dismissCorrection(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
