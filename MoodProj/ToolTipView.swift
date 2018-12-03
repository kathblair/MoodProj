//
//  ToolTipView.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-28.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class ToolTipView: UIView {
    @IBOutlet var toolTipView: UIView!
    @IBOutlet weak var moodValue: UILabel!
    @IBOutlet weak var bpmValue: UILabel!
    @IBOutlet weak var gsrValue: UILabel!
    @IBOutlet weak var tempValue: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //maybe I can create a funciton to update it and then send it what I need to update
    private func commonInit() {
        // set it up first
        Bundle.main.loadNibNamed("ToolTipView", owner: self, options:nil)
        addSubview(toolTipView)
        toolTipView.frame = self.bounds
        toolTipView.translatesAutoresizingMaskIntoConstraints = true
        toolTipView.sizeToFit()
    }
    
    public func updateValues(bpm: String, gsr: String, temp: String, mood: String){
        moodValue.text = mood
        bpmValue.text = bpm
        gsrValue.text = gsr
        tempValue.text = temp
    }
}
