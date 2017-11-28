//
//  TrackCell.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/26/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import UIKit
import SwipeCellKit

class TrackCell: SwipeTableViewCell {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistsLabel: UILabel!
    
    var animator: Any?
    
    var track: Track! {
        didSet {
            songLabel.text = track.name
            let artists = track.artists
            var artistNames: [String] = []
            for i in 0..<artists.count {
                let name = artists[i]["name"] as! String
                artistNames.append(name)
            }
            let artistString = artistNames.joined(separator: ", ")
            let likeString = track.likes == 1 ? "Like" : "Likes"
            artistsLabel.text = "\(track.likes) \(likeString) · \(artistString)"
            let imageDictionary = track.album["images"] as! [[String: Any]]
            let url = URL(string: imageDictionary[0]["url"] as! String)
            albumImage.af_setImage(withURL: url!)
        }
    }
    var liked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setLiked(_ liked: Bool, animated: Bool) {
        if #available(iOS 10, *), animated {
            var localAnimator = self.animator as? UIViewPropertyAnimator
            localAnimator?.stopAnimation(true)
            localAnimator = liked ? UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.4, animations: nil) : UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1.0, animations: nil)
            localAnimator?.addAnimations {
                self.liked = liked
            }
            localAnimator?.startAnimation()
        } else {
            self.liked = liked
        }
    }
}

enum ActionDescriptor {
    case like, unlike
    
    func title() -> String? {
        switch self {
        case .like: return "Like"
        case .unlike: return "Unlike"
        }
    }
    
    func image() -> UIImage? {
        return #imageLiteral(resourceName: "heart")
    }
    
    var color: UIColor {
        return UIColor.darkGray
    }
}

