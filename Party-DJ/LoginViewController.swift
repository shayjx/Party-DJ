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
    @IBOutlet weak var joinButton:  UIButton!
    @IBOutlet weak var gifBackgroundImage: UIImageView!
    
    let manager = APIManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        gifBackgroundImage.loadGif(name: "concert2")
        welcomeLabel.text = "Where everyone can be the DJ."
        
        // Set up Login Button
        loginButton.layer.cornerRadius = loginButton.frame.width * 0.10
        loginButton.layer.masksToBounds = true
        
        // Set up Join Button
         joinButton.layer.cornerRadius = joinButton.frame.width * 0.10
         joinButton.layer.masksToBounds = true
        
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
    
    @IBAction func didTapJoin(_ sender: Any) {
        performSegue(withIdentifier: "joinSegue", sender: self)
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
