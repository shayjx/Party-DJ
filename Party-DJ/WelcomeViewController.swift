//
//  welcomeViewController.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/26/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var defaultProfileView: UIView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var yourPlaylistButton: UIButton!
    @IBOutlet weak var createPlaylistButton: UIButton!
    @IBOutlet weak var logOutPlaylistButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupWelcomeViewController), name: Notification.Name("user.currentSetup"), object: nil)
        setupWelcomeViewController()
        
        // Make profile picture circlar
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
        defaultProfileView.layer.cornerRadius = defaultProfileView.frame.height / 2
        defaultProfileView.clipsToBounds = true
        
        // Style Join Playlist Button
        yourPlaylistButton.layer.cornerRadius = yourPlaylistButton.frame.width * 0.10
        yourPlaylistButton.layer.masksToBounds = true
        
        // Style Create Playlist Button
        createPlaylistButton.layer.cornerRadius = createPlaylistButton.frame.width * 0.10
        createPlaylistButton.layer.masksToBounds = true
        
        logOutPlaylistButton.layer.cornerRadius = logOutPlaylistButton.frame.width * 0.10
        logOutPlaylistButton.layer.masksToBounds = true
      
        
        // Render welcome instructions
        instructionsLabel.text = "Create a new playlist \nOr choose from one of your playlists."
        
        // Set up clear navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func setupWelcomeViewController() {
        if let user = User.current {
            if let url = user.profileImageURL {
                profileImage.af_setImage(withURL: URL(string: url)!)
            }
            
            // Set up text for the screen
            if user.name == "" {
                welcomeLabel.text = "Welcome!"
            } else {
                let firstName = user.name.components(separatedBy: " ").first!
                welcomeLabel.text = "Welcome, " + firstName + "!"
            }
        }
    }
    
    @IBAction func didTapCreate(_ sender: Any) {
        performSegue(withIdentifier: "createSegue", sender: self)
    }
    
    @IBAction func didTapPlaylist(_ sender: Any) {
        performSegue(withIdentifier: "playlistSegue", sender: self)
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (action) in
            APIManager.current = nil
            User.current = nil
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (action) in
        }
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true) {
            // what happens after the alert controller has finished presenting
        }
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

