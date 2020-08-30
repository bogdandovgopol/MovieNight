//
//  AuthVC.swift
//  WatchRoom
//
//  Created by Bogdan on 20/8/20.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCrashlytics

class AuthVC: UIViewController {
    //MARK: Outlets
    
    
    //MARK: Variables
    fileprivate var currentNonce: String?
    var isDarkModeEnabled = false
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createSignInWithAppleButton()
    }
    
    //MARK: Sign in with apple implementation
    func createSignInWithAppleButton() {
        let appleBtn = ASAuthorizationAppleIDButton(type: .continue, style: (traitCollection.userInterfaceStyle == .light) ? .black : .white)
        appleBtn.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(appleBtn)
        
        NSLayoutConstraint.activate([
            appleBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
            appleBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
            appleBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0),
            appleBtn.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        appleBtn.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    @objc func appleSignInTapped() {
        performSignInWithApple()
    }
    
    func performSignInWithApple() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    Crashlytics.crashlytics().log("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

//MARK: ASAuthorizationControllerDelegate implementation
extension AuthVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                Crashlytics.crashlytics().log("Invalid state: A login callback received, but no login request was sent")
                fatalError("Invalid state: A login callback received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                Crashlytics.crashlytics().log("Unable to fetch identity token")
                fatalError("Unable to fetch identity token")
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                Crashlytics.crashlytics().log("Unable to serialize token string from date: \(appleIDToken.debugDescription)")
                fatalError("Unable to serialize token string from date: \(appleIDToken.debugDescription)")
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { [weak self](result, error) in
                guard let self = self else { return }
                
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    fatalError(error.localizedDescription)
                }
                
                //check if logged in
                if let user = result?.user {
                    //check if new user
                    if let _ = result?.additionalUserInfo?.isNewUser {
                        self.registerFirestoreUser(user: user)
                    }
                    
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func registerFirestoreUser(user: User) {
        usersDb.document(user.uid).setData(["user_id" : user.uid])
    }
    
}

//MARK: ASAuthorizationControllerPresentationContextProviding implementation
extension AuthVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
