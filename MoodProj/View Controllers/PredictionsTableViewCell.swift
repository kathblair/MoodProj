//
//  PredictionsTableViewCell.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class PredictionsTableViewCell: UITableViewCell, DataProtocolClient {
    
    var dataStack: DataStack?
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    //MARK: Properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
