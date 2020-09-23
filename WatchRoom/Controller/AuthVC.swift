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
    
    var requestToken = ""
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createSignInWithAppleButton()
        createNotificationObservers()
    }
    
    //MARK: Sign in with apple implementation
    func createSignInWithAppleButton() {
        let tmdbBtn = WRTMDBSignInButton(title: "Sign in with TMDB", backgroundColor: .systemGreen)
        let appleBtn = ASAuthorizationAppleIDButton(type: .continue, style: (traitCollection.userInterfaceStyle == .light) ? .black : .white)
        appleBtn.translatesAutoresizingMaskIntoConstraints = false
        appleBtn.layer.cornerRadius = 7
        
        view.addSubview(tmdbBtn)
        view.addSubview(appleBtn)
        
        print(appleBtn.layer.cornerRadius)
        
        NSLayoutConstraint.activate([
            appleBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
            appleBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
            appleBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0),
            appleBtn.heightAnchor.constraint(equalToConstant: 50.0),
            
            tmdbBtn.centerXAnchor.constraint(equalTo: appleBtn.centerXAnchor),
            tmdbBtn.widthAnchor.constraint(equalTo: appleBtn.widthAnchor),
            tmdbBtn.heightAnchor.constraint(equalToConstant: 50),
            tmdbBtn.bottomAnchor.constraint(equalTo: appleBtn.topAnchor, constant: -20.0)
        ])
        
        appleBtn.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        tmdbBtn.addTarget(self, action: #selector(tmdbSignInTapped), for: .touchUpInside)
    }
    
    @objc func appleSignInTapped() {
        performSignInWithApple()
    }
    
    @objc func tmdbSignInTapped() {
        TMDBAuthService.shared.createRequestToken { [weak self](requestToken) in
            guard let self = self else { return }
            guard let requestToken = requestToken else { return }
            guard let url = URL(string: TMDB_API.v4.Auth.RequestTokenRedirectURL + requestToken) else { return }
            self.requestToken = requestToken
            DispatchQueue.main.async {
                self.presentSafariVC(with: url)
            }
        }
    }
    
    func createNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(TMDBAuthApproved), name: NotificationKeys.TMDBAuthApprovedKey, object: nil)
    }
    
    @objc func TMDBAuthApproved() {
        TMDBAuthService.shared.getCredentials(withRequestToken: requestToken) { [weak self](credentials) in
            guard let self = self else { return }
            guard let credentials = credentials else {
                self.presentSimpleAlert(withTitle: "Something went wrong", message: "Unable to log you in with TMDB account. Please try again.")
                return
            }
            PersistanceService.updateCredentials(with: credentials, actionType: .add) { [weak self](error) in
                guard let self = self else { return }
                if let error = error {
                    self.presentSimpleAlert(withTitle: "Something went wrong", message: error.rawValue)
                }
                DispatchQueue.main.async {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
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
                    
                    self.dismiss(animated: true, completion: nil)
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
