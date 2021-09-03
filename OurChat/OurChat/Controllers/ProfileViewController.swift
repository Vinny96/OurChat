//
//  ProfileViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class ProfileViewController: UIViewController, UITableViewDataSource {

    // IBOutlets
    @IBOutlet var tableView : UITableView!
    
    
    // properties
    let spinner = JGProgressHUD(style: .dark)
    let storageManagerReference = StorageManager.shared
    let tableViewData = ["Log Out"]
    let standardUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intitalizeVC()
    }
        
    // MARK: - UI Functions
    private func createTableHeader() -> UIView?
    {
        guard let loggedInUserEmail = standardUserDefaults.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) as? String else{return nil}
        
        let fileName = loggedInUserEmail + "_profilePicture.jpg"
        let path = "images/"+fileName

        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        tableHeaderView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (tableHeaderView.width - 150) / 2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        tableHeaderView.addSubview(imageView)
        setImageForProfileImageView(pathProvided: path, imageViewToUse: imageView)
        return tableHeaderView
    }
    
    private func setImageForProfileImageView(pathProvided : String, imageViewToUse : UIImageView)
    {
        spinner.show(in: imageViewToUse)
        // so we want to see if the downloadURL exists in the userdefaults and if it does we will use that one. If it does not we will have to use the storageManager to get it
        if let downloadURL = standardUserDefaults.value(forKey: UserDefaultKeys.userProfilePictureDownloadURLKey) as? URL
        {
            URLSession.shared.dataTask(with: downloadURL) { data, _, error in
                guard let safeData = data, error == nil else {
                    print("There was an error in downloading the image from the URL provided. \(error!)")
                    return
                }
                // success
                DispatchQueue.main.async {
                    self.spinner.dismiss()
                    imageViewToUse.image = UIImage(data: safeData)
                }
            }.resume()
        }
        else
        {
            // so here we were not able to get a URL from the value saved into the persistent store
            var downloadURLAsString : String?
            storageManagerReference.getDownloadURL(for: pathProvided) {[weak self] result in
                switch result
                {
                case .success(let downloadURL):
                    downloadURLAsString = downloadURL
                    print("Success in getting the downloadURL from the profile view controller: \(downloadURL)")
                    guard let safeDownloadURLAsString = downloadURLAsString else{return}
                    self?.standardUserDefaults.set(safeDownloadURLAsString, forKey: UserDefaultKeys.userProfilePictureDownloadURLKey)
                    guard let downloadURLToUse = URL(string: safeDownloadURLAsString) else {return}
                    
                    URLSession.shared.dataTask(with: downloadURLToUse) { data, _, error in
                        guard let safeData = data, error == nil else {
                            print("There was an error in getting data from the downloadURL provided. \(error!)")
                            return
                        }
                        // success
                        DispatchQueue.main.async {
                            print("spinner should be dismissed by now")
                            self?.spinner.dismiss()
                            imageViewToUse.image = UIImage(data: safeData)
                        }
                    }.resume()
                    
                case .failure(let error):
                    print("There was an error in getting the downloadURL from the path provided. \(error)")
                    return
                }
            }
        }
    }
    
    
    // MARK: - Functions
    private func intitalizeVC()
    {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    
    
}


extension ProfileViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableViewData[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        presentSignOutAlertToUser()
    }
    
    // Firebase functions and related functions
    func presentSignOutAlertToUser()
    {
        let actionSheet = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "Sign Out", style: .destructive) {[weak self] _ in
            self?.signOutWithFirebase()
        }
        let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(yesAction)
        actionSheet.addAction(noAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func signOutWithFirebase()
    {
        // facebook and google signout
        signUserOutOfFacebook()
        GIDSignIn.sharedInstance.signOut()
        do
        {
            try FirebaseAuth.Auth.auth().signOut()
            // here is where we want to clear the userDefaults curently logged in user email.
            standardUserDefaults.set("placeholder", forKey: UserDefaultKeys.userProfilePictureDownloadURLKey)
            standardUserDefaults.set("emailPlaceHolder", forKey: UserDefaultKeys.loggedInUserSafeEmail)
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        catch
        {
            print("Failed to log out")
        }
    }
    
    func signUserOutOfFacebook()
    {
       let loginManager = LoginManager()
        loginManager.logOut()
    }
    
}
