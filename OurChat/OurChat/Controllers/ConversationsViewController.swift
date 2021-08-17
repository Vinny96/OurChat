//
//  ViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    // properties
    var standardUserDefaults = UserDefaults.standard
    var firebaseObject = FirebaseAuth.Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Converations"
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserIsLoggedIn()
    }

    
    
    
    
    
    // MARK: - Functions
    private func checkIfUserIsLoggedIn()
    {
        if firebaseObject.currentUser == nil
        {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        
        
    }


}

