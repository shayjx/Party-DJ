//
//  ViewController.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/24/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var gifBackgroundImage: UIImageView!
    
    let manager = APIManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        gifBackgroundImage.loadGif(name: "party")
        welcomeLabel.text = "Where everyone can be the DJ."
        
          APIManager.current = manager
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        if UIApplication.shared.openURL(manager.loginURL!) {
            if manager.auth.canHandle(manager.auth.redirectURL) {
                NotificationCenter.default.addObserver(self, selector: #selector(readyforSegue), name: Notification.Name("loginSuccessful"), object: nil)
            }
        }
    }
    
    @objc func readyforSegue() {
        performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
