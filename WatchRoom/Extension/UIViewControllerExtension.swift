//
//  UIViewControllerExtension.swift
//  WatchRoom
//
//  Created by Bogdan on 20/8/20.
//

import Foundation
import UIKit
import Firebase

extension UIViewController {
    func isUserSignedIn() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }

            if user == nil {
                //user not logged in or not verified
                //present SignInVC
                self.presentSignInVC()
            }
        }
    }
    
    private func presentSignInVC(){
        let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: VCIDs.SignInVC)
        present(controller, animated: false, completion: nil)
    }
}
