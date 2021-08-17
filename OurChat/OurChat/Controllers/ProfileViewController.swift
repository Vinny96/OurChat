//
//  ProfileViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDataSource {

    // IBOutlets
    @IBOutlet var tableView : UITableView!
    
    
    // properties
    let tableViewData = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intitalizeVC()
    }
        
    // MARK: - Functions
    private func intitalizeVC()
    {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
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
        do
        {
            try FirebaseAuth.Auth.auth().signOut()
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
    
    
}
