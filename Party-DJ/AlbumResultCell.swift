//
//  AlbumCell.swift
//  Kickback
//
//  Created by Daniel Afolabi on 7/21/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class AlbumResultCell: UITableViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
        
    var album: Album! {
        didSet {
            // Setting up the album title
            albumNameLabel.text = album.name
            let artistName = album.artists
            artistNameLabel.text = artistName[0]["name"] as! String
            
            // Set the image of the album
            if !album.images.isEmpty {
                let imageDictionary = album.images
                let url = URL(string: imageDictionary[0]["url"] as! String)
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
