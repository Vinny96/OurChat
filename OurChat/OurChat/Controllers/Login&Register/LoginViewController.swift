//
//  LoginViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {

    // properties
    let firebaseAuthObject = FirebaseAuth.Auth.auth()
    let databaseManager = DatabaseManager.shared
    let GIDSignInSharedInstance = GIDSignIn.sharedInstance
    
    
    // UI properties
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView : UIScrollView = {
        let scrolView = UIScrollView()
        scrolView.clipsToBounds = true
        return scrolView
    }()
    
    private let emailField : UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Email Address...."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
    }()
    
    private let passwordField : UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Password..."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton : FBLoginButton = {
        let loginButton = FBLoginButton()
        loginButton.permissions = ["email" , "public_profile"]
        loginButton.layer.cornerRadius = 12
        loginButton.layer.masksToBounds = true
        return loginButton
    }()
    
    private let googleSignInButton : GIDSignInButton = {
        let googleLoginButton = GIDSignInButton()
        googleLoginButton.layer.cornerRadius = 12
        googleLoginButton.layer.masksToBounds = true
        return googleLoginButton
    }()
    
    
    // MARK: - System called functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(didTapRegister))
        addAllSubViews()
        initializeDelegates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeScrollView()
        initializeImageView()
        initializeEmailField()
        initializePasswordField()
        initializeLoginButton()
        initializeFBLoginButton()
        initializeGoogleSignInButton()
    }
    
    
    // MARK: - Initializing UI and ViewController
    
    private func initializeDelegates()
    {
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
    }
    
    private func initializeScrollView()
    {
        scrollView.frame = view.bounds
    }
    
    private func initializeImageView()
    {
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 20, width: size, height: size)
    }
    
    private func initializeEmailField()
    {
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    private func initializePasswordField()
    {
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    private func initializeLoginButton()
    {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    private func initializeFBLoginButton()
    {
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame = CGRect(x: 30, y: loginButton.bottom + 10, width:  scrollView.width - 60, height: 52)
    }
    
    private func initializeGoogleSignInButton()
    {
        googleSignInButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        googleSignInButton.center = scrollView.center
        googleSignInButton.frame = CGRect(x: 30, y: facebookLoginButton.bottom + 10, width: scrollView.width - 60, height:  52)
        
    }
    
    private func addAllSubViews()
    {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleSignInButton)
    }
    
    
    // MARK: - OBJC Methods
    @objc private func didTapRegister()
    {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func loginButtonTapped()
    {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            return
        }
        // implement fireabse login
        logInUserWithFirebase(email: email, password: password) {[weak self] result in
            switch result {
                
            case .success(let successString):
                print(successString)
                DispatchQueue.main.async {
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
            
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self?.alertUserOfSignInError()
                }
            }
        }
    }
    
    @objc private func googleLoginButtonTapped()
    {
        signUserInWithGoogle()
    }

    // MARK: - Functions
    private func alertUserRegardingEmptyFields()
    {
        let alertController = UIAlertController(title: "Whoops", message: "Please make sure your email and password are not empty and that the password is greater than 6 characters.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
        
    }
    
    
    // MARK: - Firebase Functions
    private func logInUserWithFirebase(email : String, password : String, completion : @escaping (Result<String,Error>) -> Void)
    {
        firebaseAuthObject.signIn(withEmail: email, password: password) { authDataResult, error in
            guard let result = authDataResult, error == nil else {
                completion(.failure(error!))
                return
            }
            // here we have a success
            print(result.user)
            let signInSuccess = "Sign in successful"
            // here we want to store the logged in users email into userDefaults. 
            completion(.success(signInSuccess))
        }
    }
    
    private func signUserInWithGoogle()
    {
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow
        GIDSignInSharedInstance.signIn(with: config, presenting: self) {[weak self] user, error in
            if let errorPresent = error
            {
                print("There was an error signing in with google: \(errorPresent)")
                return
            }
            guard let authenticaton = user?.authentication,
                  let idToken = authenticaton.idToken else {
                return
            }
            let googleCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authenticaton.accessToken)
            
            // getting the info to create our ChatAppUser object
            guard let safeUser = user else {return}
            guard let newChatAppUserEmail = safeUser.profile?.email,
                  let newChatAppUserFirstName = safeUser.profile?.givenName,
                  let newChatAppUserLastName = safeUser.profile?.familyName else {return}
            
            let newChatAppUser = ChatAppUser(firstNameVal: newChatAppUserFirstName, lastNameVal: newChatAppUserLastName, emailVal: newChatAppUserEmail)
            
            // checking if user exists in the DB
            self?.databaseManager.checkIfUserExistsInDB(chatAppUserToCheck: newChatAppUser) { result in
                switch result {
                case true:
                    self?.signInUserWithFirebaseCredential(credentialToUse: googleCredential)
                    return
                case false:
                    self?.databaseManager.writeNewUserToDB(chatAppUserToInsert: newChatAppUser, completion: { databaseManagerWriteResult in
                        switch databaseManagerWriteResult {
                        case .success(let success):
                            print("Successfully wrote ChatAppUser to the database in sign in with google method \(success)")
                            self?.signInUserWithFirebaseCredential(credentialToUse: googleCredential)
                            return
                        case .failure(let error):
                            print("Unable to add user to database running from sign user in with google method: \(error)")
                            // we also want to present some kind of error message to the user to let them know what is going on.
                            return
                        }
                    })
                }
            }
        }
    }
    
    private func signInUserWithFirebaseCredential(credentialToUse : AuthCredential)
    {
        firebaseAuthObject.signIn(with: credentialToUse) {[weak self] authResult, error in
            guard authResult != nil, error == nil else {
                if let error = error {
                    print("credential failed.\(error)")
                }
                return
            }
            // success here
            print("Success in signing user in with firebase credential.")
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func alertUserOfSignInError()
    {
        let alertController = UIAlertController(title: "Whoops", message: "There was an error signing you in please make sure that the email and password provided is correct.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    private func alertUserOfFacebookSignInError()
    {
        let alertController = UIAlertController(title: "Whoops", message: "There was an error signing you in with Facebook please try again.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
}

extension LoginViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == emailField)
        {
            passwordField.becomeFirstResponder()
        }
        else if (textField == passwordField)
        {
            loginButtonTapped()
        }
        return true
    }
    
    
}

extension LoginViewController : LoginButtonDelegate
{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
        // logout operations 
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?)
    {
        guard let tokenAsString = result?.token?.tokenString else
        {
            print("Failed to login with Facebook")
            return
        }
        // so this is where we need to exchange our token for a firebase token
        let firebaseCredential = FacebookAuthProvider.credential(withAccessToken: tokenAsString)
        callFBGraphRequest(facebookTokenString: tokenAsString) {[weak self] result in
            switch result {
            case true:
                self?.signInUserWithFirebaseCredential(credentialToUse: firebaseCredential)
            case false:
                print("Error in signing user in Facebook")
            }
        }
    }
    
   
    
    
    /// Starts GraphRequest so we can populate the database if the user does not exist and if they do already exist we simply return from the function
    func callFBGraphRequest(facebookTokenString : String, completion : @escaping (Bool) -> Void)
    {
        let facebookGraphRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email, first_name, last_name"], tokenString: facebookTokenString, version: nil, httpMethod: .get)
        facebookGraphRequest.start { [weak self] _, result, error in
            guard let safeResult = result as? [String : Any], error == nil else{
                print("Graph Request has failed")
                return
            }
            
            // now we need to extract the necessary information from the fields
            guard let firstName = safeResult["first_name"] as? String else{
                completion(false)
                return
            }
            guard let lastName = safeResult["last_name"] as? String else{
                completion(false)
                return}
            guard let email = safeResult["email"] as? String else {
                completion(false)
                return}
            print(firstName)
            print(lastName)
            print(email)
            
            // now we need to create our ChatAppUser, make sure that email does not already exist and if it does not we pass in false into our completion handler
            let newChatAppUser = ChatAppUser(firstNameVal: firstName, lastNameVal: lastName, emailVal: email)
            self?.databaseManager.checkIfUserExistsInDB(chatAppUserToCheck: newChatAppUser, completion: { result in
                if result == true
                {
                    // here this means the user already exists
                    completion(true)
                    return
                }
                // so when we get here this means that the use does not exist
                else
                {
                    self?.databaseManager.writeNewUserToDB(chatAppUserToInsert: newChatAppUser, completion: { result in
                        switch result {
                        case .success(let sucess):
                            print(sucess)
                            print("Successfully signed new user in with Facebook and wrote to the database")
                            completion(true)
                        case .failure(let error):
                            print(error)
                            completion(false)
                        }
                    })
                }
            })
        }
    }
}
