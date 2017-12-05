//
//  JoinController.swift
//  Party-DJ
//
//  Created by Shana Joseph on 12/4/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class JoinController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapJoin(_ sender: Any) {
        performSegue(withIdentifier: "createSuccessSegue", sender: self)
    }
    
}
