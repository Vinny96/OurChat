//
//  ViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit

class ConversationsViewController: UIViewController {

    var standardUserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Converations"
        view.backgroundColor = .red
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserIsLoggedIn()
    }

    
    
    
    
    
    // MARK: - Functions
    private func checkIfUserIsLoggedIn()
    {
        let valueReturned = standardUserDefaults.bool(forKey: UserDefaultKeys.isUserLoggedInKey)
        if !valueReturned
        {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }


}

