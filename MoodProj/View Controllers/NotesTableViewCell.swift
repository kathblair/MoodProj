//
//  NotesTableViewCell.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-21.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var noteDateLabel: UILabel!
    @IBOutlet weak var noteTimeLabel: UILabel!
    @IBOutlet weak var noteContextTitleLabel: UILabel!
    @IBOutlet weak var noteContextRangeLabel: UILabel!
    @IBOutlet weak var noteTextContainer: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
