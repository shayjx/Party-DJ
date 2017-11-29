//
//  PlaylistViewController.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/28/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class PlaylistViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

@IBAction func didTapPLaylist(_ sender: Any) {
    performSegue(withIdentifier: "createSuccessSegue", sender: self)
}

}
