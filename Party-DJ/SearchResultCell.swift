//
//  SearchResultCell.swift
//  Kickback
//
//  Created by Daniel Afolabi on 7/16/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistsLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var addTrackImageView: UIImageView!
    
    var track: Track! {
        didSet {
            nameLabel.text = track.name
            
            // Setting up artist label
            let artists = track.artists
            var artistNames: [String] = []
            for i in 0..<artists.count {
                let name = artists[i]["name"] as! String
                artistNames.append(name)
            }
            artistsLabel.text = artistNames.joined(separator: ", ")
            
            // Setting up the album image
            if !(track.album["images"] as! [[String: Any]]).isEmpty {
                let imageDict = track.album["images"] as! [[String: Any]]
                let url = URL(string: imageDict[0]["url"] as! String)
                albumImageView.af_setImage(withURL: url!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumImageView.layer.borderWidth = 1
        albumImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
