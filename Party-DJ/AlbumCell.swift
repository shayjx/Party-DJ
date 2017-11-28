//
//  AlbumCell.swift
//  Kickback
//
//  Created by Daniel Afolabi on 7/21/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!    
    var album: Album! {
        didSet {
            // Set the image of the album
            let imageDictionary = album.images
            let url = URL(string: imageDictionary[0]["url"] as! String)
            albumImageView.af_setImage(withURL: url!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumImageView.layer.borderWidth = 1
        albumImageView.layer.borderColor = UIColor.white.cgColor
    }
    
}
