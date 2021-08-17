//
//  LoginViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // properties
    let firebaseAuthObject = FirebaseAuth.Auth.auth()
    
    
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
    
    
    // System called functions
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
    
    private func addAllSubViews()
    {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
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
            // pass in the value to user defaults here
            completion(.success(signInSuccess))
        }
    }
    
    private func signInUserWithFirebaseCredential(credentialToUse : AuthCredential)
    {
        firebaseAuthObject.signIn(with: credentialToUse) {[weak self] authResult, error in
            guard authResult != nil, error == nil else {
                if let error = error {
                    print("Facebook login credential failed.\(error)")
                }
                return
            }
            // success here
            print("Success")
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
    
    // stopped at 24:56
    
}

extension LoginViewController : LoginButtonDelegate
{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
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
        signInUserWithFirebaseCredential(credentialToUse: firebaseCredential)
    }
}
