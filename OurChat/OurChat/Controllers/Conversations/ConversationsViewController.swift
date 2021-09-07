//
//  ViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {

    // properties
    var standardUserDefaults = UserDefaults.standard
    var firebaseObject = FirebaseAuth.Auth.auth()
    
    
    // UI Properties
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversationsLabel : UILabel = {
        let label = UILabel()
        label.text = "No conversations"
        label.textAlignment = .center
        label.textColor  = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    

    // MARK: - System Called Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        createComposeNewMessageButton()
        title = "Conversations"
        addSubviews()
        setupTableView()
        fetchConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeTableView()
        initializeNoConversationsLabel()
    }
    
    
    // MARK: - UI Functions
    private func createComposeNewMessageButton()
    {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
    }
    
    private func initializeTableView()
    {
        tableView.frame = view.bounds
    }
    
    private func initializeNoConversationsLabel()
    {
        noConversationsLabel.frame = CGRect(x: view.width / 4, y: (view.height - 200) / 2, width: view.width, height: 200)
    }
    
    // MARK: - OBJC Functions
    @objc private func didTapComposeButton()
    {
        let vc = NewConversationViewController()
        vc.completion = {[weak self] result in
            guard let strongSelf = self else{return}
            DispatchQueue.main.async {
                strongSelf.createNewConversation(result: result)
            }
        }
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Functions
    
    private func addSubviews()
    {
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
    }
    
    private func setupTableView()
    {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createNewConversation(result : [String : String])
    {
        guard let fullName = result["full_name"],
              let recipientEmail = result["safe_email"] else{return}
        let vc = ChatViewController(with: recipientEmail)
        vc.title = fullName
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated:  true)
        
    }
    
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
    
    private func fetchConversations()
    {
        // fetch conversations from firebase
        tableView.isHidden = false
    }
}
//MARK: - Extensions

extension ConversationsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Hello World"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //let vc = ChatViewController() // will be extended and instantiated with the name of the user we want to chat with
      //  vc.title = "Jenny Smith"
      //  vc.navigationItem.largeTitleDisplayMode = .never
      //  navigationController?.pushViewController(vc, animated: true)
    }
    
}
