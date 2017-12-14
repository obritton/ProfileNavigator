//
//  ProfileViewController.swift
//  ProfileNavigator
//
//  Created by Ontario Britton on 12/13/17.
//  Copyright © 2017 Ontario Britton. All rights reserved.
//

import UIKit
import MessageUI

let bumpOffset : CGFloat = 10
//ProfileViewController shows an image and information for a Profile
class ProfileViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profilePic: LazyImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    var profile : Profile?
    static var increment = 0
    
    var hintTimer : Timer?
    let hasShownHintKey = "has shown hint"
    
    //Fetches a Profile and (re)populates the UI
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        ProfileManager.shared.getProfile(offsetFromCurrentProfile: ProfileViewController.increment) { (success, profile) in
            self.profile = profile
            if success, let profile = profile {
                self.usernameLbl.text = profile.username
                self.nameLbl.text = profile.name.capitalized
                self.mobileLbl.text = profile.mobile
                self.emailLbl.text = profile.email
                self.addressLbl.text = profile.addressLine1.capitalized + "\n" + profile.addressLine2.capitalized
                UIView.animate(withDuration: 0.25, animations: {
                    self.usernameLbl.alpha = 1
                    self.nameLbl.alpha = 1
                    self.mobileLbl.alpha = 1
                    self.emailLbl.alpha = 1
                    self.addressLbl.alpha = 1
                })
                
                if let imageURL = URL(string: profile.photoURLStr) {
                    self.profilePic.loadURL(url: imageURL)
                }
            }
            ProfileViewController.increment = 0
        }
        
        //Schedule a hint showing that profiles are swipable
        if !UserDefaults.standard.bool(forKey: hasShownHintKey) {
            hintTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
                self.bump(with: -bumpOffset)
            }
        }
    }
    
    //Navigates left or right through a list of Profiles
    @IBAction func handleSwipe( swipe: UISwipeGestureRecognizer) {
        switch swipe.direction {
        case .left:
            hintTimer?.invalidate()
            UserDefaults.standard.set(true, forKey: hasShownHintKey)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController else { return }
            ProfileViewController.increment = 1
            self.navigationController?.pushViewController(profileViewController, animated: true)
        default:
            ProfileViewController.increment = -1
            self.navigationController?.popViewController(animated: true)
            bump(with: bumpOffset)
        }
    }
    
    func bump(with offset: CGFloat) {
        self.view.center = CGPoint(x: self.view.center.x + offset, y: self.view.center.y)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.center = CGPoint(x: self.view.center.x - offset, y: self.view.center.y)
        })
    }
    
    //Prepares a phone call to this Profile's mobile
    @IBAction func tappedMobile(_ sender: UIButton) {
        guard let profile = profile, let url = URL(string: "tel://\(profile.mobile)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    //Initaiates an email to this Profile's email
    @IBAction func tappedEmail(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Cannot send mail", message: "Make sure this device is setup for email", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.navigationController?.dismiss(animated: true, completion: nil)
            }))
            self.navigationController?.present(alert, animated: true, completion: nil)
            
            return
        }
        guard let profile = profile else { return }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([profile.email])
        mailViewController.setSubject("Hi \(profile.username)")
        mailViewController.setMessageBody("", isHTML: false)
        present(mailViewController, animated: true, completion: nil)
    }
    
    //Dismisses the initiated email
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
