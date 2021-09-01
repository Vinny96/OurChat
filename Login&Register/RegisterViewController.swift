//
//  RegisterViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseStorage

class RegisterViewController: UIViewController {

    // properties
    let firebaseAuthObject = FirebaseAuth.Auth.auth()
    let firebaseStorageRef = StorageManager.shared

    
    // UI properties
    private let profilePictureImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let scrollView : UIScrollView = {
        let scrolView = UIScrollView()
        scrolView.clipsToBounds = true
        return scrolView
    }()
    
    private let firstNameField : UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "First Name...."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
    }()
    
    private let lastNameField : UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "lastName...."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
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
    
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    
    // System called functions
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        title = "Register"
        view.backgroundColor = .white
        addAllSubViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeScrollView()
        initializeProfilePictureImageView()
        initializeFirstNameField()
        initializeLastNameField()
        initializeEmailField()
        initializePasswordField()
        initializeRegisterButton()
    }
    
    
    // MARK: - Initializing UI and ViewController
    
    private func initializeDelegate()
    {
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    private func initializeScrollView()
    {
        scrollView.frame = view.bounds
        //scrollView.isUserInteractionEnabled = true
    }
    
    private func initializeProfilePictureImageView()
    {
        let size = scrollView.width / 3
        profilePictureImageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 20, width: size, height: size)
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.width / 2
        initializeProfileImageViewGesture()
    }
    
    
    private func initializeFirstNameField()
    {
        firstNameField.frame = CGRect(x: 30, y: profilePictureImageView.bottom + 10, width: scrollView.width - 60 , height: 52)
    }
    
    private func initializeLastNameField()
    {
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    
    private func initializeEmailField()
    {
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    private func initializePasswordField()
    {
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    private func initializeRegisterButton()
    {
        registerButton.addTarget(self, action: #selector(registerNewUser), for: .touchUpInside)
        registerButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    private func addAllSubViews()
    {
        view.addSubview(scrollView)
        scrollView.addSubview(profilePictureImageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
    }
    
    
    // MARK: - OBJC Methods
    @objc private func registerNewUser()
    {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text ,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty ,!email.isEmpty,
              !password.isEmpty, password.count >= 6
        else {
            DispatchQueue.main.async {
                self.alertUserRegardingEmptyFields()
            }
            return
        }
        // so here we want to check if the user exists prior to registering the user with Firebase
        let chatAppUser = ChatAppUser(firstNameVal: firstName, lastNameVal: lastName, emailVal: email)
        
        DatabaseManager.shared.checkIfUserExistsInDB(chatAppUserToCheck: chatAppUser) {[weak self] doesExist in
            if doesExist == true
            {
                // here we want to present a message telling the user that another user with that email already exists
                DispatchQueue.main.async {
                    self?.userAlreadyExistsInFirebaseMessage()
                }
                return
            }
            else
            {
                // so here the user does not exist so we can registerUserTheUser
                self?.registerUserWithEmailAndPassword(firstName: firstName, lastName: lastName, email: email, password: password) {registerUserResult in
                    switch registerUserResult {
                    
                    case .success(let successString):
                        print(successString)
                        // now we can write our user to the database
                        DatabaseManager.shared.writeNewUserToDB(chatAppUserToInsert: chatAppUser) { databaseInsertResult in
                            switch databaseInsertResult {
                            
                            case .success(_):
                                print("Successfully wrote the user to the database")
                            case .failure(_):
                                print("There was an error in writing the user to the database.")
                            }
                        }
                        self?.navigationController?.dismiss(animated: true, completion: nil)
                        
                    case .failure(let error):
                        print(error)
                        self?.presentErrorMessageWithFirebaseRegister()
                        return
                    }
                }
            }
        }
    }

    @objc private func didTapChangeProfilePicture()
    {
        print("running in didTapChangeProfilePicture")
        presentActionSheet()
    }
    
    // MARK: - Functions
    private func alertUserRegardingEmptyFields()
    {
        let alertController = UIAlertController(title: "Whoops", message: "Please enter all information to create a new account.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
        
    }
    
    private func initializeProfileImageViewGesture()
    {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        profilePictureImageView.addGestureRecognizer(gesture)
        profilePictureImageView.isUserInteractionEnabled = true
    }
    
    // MARK: - Firebase Authentication functions and other related Firebase functions
    private func registerUserWithEmailAndPassword(firstName : String, lastName : String, email : String, password : String, completion : @escaping (Result<String,Error>) -> Void)
    {
        let ChatAppUser = ChatAppUser(firstNameVal: firstName, lastNameVal: lastName, emailVal: email)
        
        firebaseAuthObject.createUser(withEmail: ChatAppUser.email, password: password) {[weak self] authDataResult, error in
            guard let dataResult = authDataResult, error == nil else {
                completion(.failure(error!))
                return
            }
            // success
            print(dataResult.user)
            let successString = "Successfully registered the user with Firebase"
           
            // so here is where we now want to upload the pngData to firebase storage
            let urlFileName = ChatAppUser.profilePictureURLFileName
            guard let profilePicturePNGData = self?.profilePictureImageView.image?.pngData() else {return}
            
            self?.firebaseStorageRef.uploadProfilePictureToStorage(dataToUpload: profilePicturePNGData, fileName: urlFileName) { result in
                switch result {
               
                case .success(let downloadURLAsString):
                    // here we are caching the downloadURLAsString
                    print("success in getting downloadURL: \(downloadURLAsString) ")
                    UserDefaults.standard.set(downloadURLAsString, forKey: UserDefaultKeys.userProfilePictureDownloadURLKey)
                    
                case .failure(let error):
                    print("There was an error in getting the downloadURL for the users profile picture: \(error)")
                    completion(.failure(error))
                    return
                }
            }
            completion(.success(successString))
        }
    }
    
    private func presentErrorMessageWithFirebaseRegister()
    {
        let alertController = UIAlertController(title: "Woops", message: "There was an issue in registering you with our servers. Please try again." , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// This is going to be used to inform the user that another user with that email address already exists
    private func userAlreadyExistsInFirebaseMessage()
    {
        let alertController = UIAlertController(title: "Woops", message: "Another user with that email already exists. Please use a differnt email.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
}

// MARK: - Extensions

extension RegisterViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField
        {
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField
        {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            registerNewUser()
        }
        return true
    }
}

extension RegisterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func presentActionSheet()
    {
        let actionSheetController = UIAlertController(title: "Profile Picture", message: "Please select one of the options from below.", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            DispatchQueue.main.async {
                self.presentCamera()
            }
        }
        let photoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            DispatchQueue.main.async {
                self.presentPhotoPicker()
            }
        }
        actionSheetController.addAction(cameraAction)
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dismisss this view controller
        picker.dismiss(animated: true, completion: nil)
    }
    
    func presentCamera()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
        
    }
}


extension RegisterViewController : PHPickerViewControllerDelegate
{
  
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {
        // so here we need to get the first image from PHPickerResult
        guard let safeFirstResult = results.first else {return}
        safeFirstResult.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
            guard let firstResultAsImage = object as? UIImage else {
                return
            }
            // success
            DispatchQueue.main.async {
                self.profilePictureImageView.image = firstResultAsImage
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func presentPhotoPicker()
    {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let photoPicker = PHPickerViewController(configuration: configuration)
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    
}
