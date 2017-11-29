//
//  InviteCell.swift
//
//

import UIKit

class InviteCell: UITableViewCell {

    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
//    var invite: Invite? {
//        didSet {
//            playlistLabel.text = invite.playlistName
//            ownerLabel.text = invite.username ?? invite?.userId
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
