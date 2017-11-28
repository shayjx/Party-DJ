//
//  joinHomeViewController.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/26/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//


import UIKit
import Parse
import AVFoundation

class JoinViewController: UIViewController, UITextViewDelegate, QRCodeReaderViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var emptyInvitesLabel: UILabel!
    @IBOutlet weak var invitesTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    var user = User.current!
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    var invites: [Invite] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change the color of the back button in the navigation bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // style buttons
        for button in [searchButton, scanButton] {
            button!.layer.cornerRadius = button!.frame.height / 2
            button!.layer.masksToBounds = false
            button!.clipsToBounds = true
        }
        
        // load invites
        reloadInvites()
        
        // table view
        invitesTableView.delegate = self
        invitesTableView.dataSource = self
        invitesTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    
    @IBAction func onSearch(_ sender: Any) {
        performSegue(withIdentifier: "enterAccessCodeSegue", sender: nil)
    }
    
    @IBAction func onScan(_ sender: Any) {
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func changeSelectedColor(_ sender: Any) {
        let button = sender as! UIButton
        button.alpha = 0.1
    }
    
    @IBAction func changeNormalColor(_ sender: Any) {
        let button = sender as! UIButton
        button.alpha = 0.25
    }
    
    // MARK: - Table view
    
    func reloadInvites() {
        let query = PFQuery(className: "Invite").whereKey("inviteeId", equalTo: user.id)
        query.findObjectsInBackground { (results, error) in
            if let error = error {
                print("Error loading invites: \(error.localizedDescription)")
            } else {
                self.invites = []
                for parseInvite in results! {
                    self.invites.append(Invite(parseInvite))
                }
                self.emptyInvitesLabel.isHidden = !self.invites.isEmpty
                self.invitesTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell", for: indexPath) as! InviteCell
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor(red: 0.20, green: 0.07, blue: 0.31, alpha: 1.0)
        cell.selectedBackgroundView = backgroundColorView
        let invite = invites[indexPath.row]
        cell.playlistLabel.text = invite.queueName
        cell.ownerLabel.text = invite.inviterName ?? invite.inviterId
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let invite = invites[indexPath.row]
        Invite.removeInvite(queueId: invite.queueId, userId: invite.inviteeId)
        tryJoinQueueWith(code: invite.queueCode)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true) {
            self.tryJoinQueueWith(code: result.value)
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func tryJoinQueueWith(code: String) {
        let query = PFQuery(className: "Queue").whereKey("accessCode", equalTo: code)
        query.getFirstObjectInBackground(block: { (parseQueue: PFObject?, error: Error?) in
            if let error = error {
                // There is no queue with that access code.
                
                // create the alert
                let alert = UIAlertController(title: "Invalid Playlist Code", message: "We can't find a playlist with this code. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                print(error.localizedDescription)
            } else {
                let queue = Queue(parseQueue!)
                queue.addMember(userId: self.user.id)
                self.user.add(queueId: queue.id)
                self.performSegue(withIdentifier: "joinSuccessSegue", sender: self)
                Queue.current = queue
            }
        })
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

