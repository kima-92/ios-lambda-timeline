//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by macbook on 12/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
