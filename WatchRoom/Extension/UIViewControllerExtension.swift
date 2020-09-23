//
//  UIViewControllerExtension.swift
//  WatchRoom
//
//  Created by Bogdan on 20/8/20.
//

import Foundation
import UIKit
import FirebaseAuth
import SafariServices

enum SignInType {
    case firebase, tmdb
}

extension UIViewController {
    func isUserSignedIn(completion: @escaping (SignInType?) -> Void) {
        isFirebaseSignedIn { [weak self](fbSingnedIn) in
            guard let self = self else { return }
            
            if fbSingnedIn == false {
                self.isTMDBSignedIn { (tmdbSignedIn) in
                    if tmdbSignedIn == false {
                        completion(nil)
                    } else {
                        completion(.tmdb)
                    }
                }
            } else {
                completion(.firebase)
            }
        }
    }
    
    private func isFirebaseSignedIn(completion: @escaping (Bool) -> Void) {
        Auth.auth().addStateDidChangeListener {(auth, user) in
            if user != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func isTMDBSignedIn(completion: @escaping (Bool) -> Void) {
        PersistanceService.retrieveTMDBCredentials { (result) in
            switch result {
            case .success(let credentials):
                if credentials == nil {
                    completion(false)
                    return
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func presentSignInVC(){
        let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: VCIDs.SignInVC)
        present(controller, animated: true, completion: nil)
    }
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemGreen
        present(safariVC, animated: true, completion: nil)
        
    }
    
    func presentSimpleAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

