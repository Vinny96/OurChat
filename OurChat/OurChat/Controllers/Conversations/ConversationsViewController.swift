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
    var sharedDatabaseObj = DatabaseManager.shared
    
    
    // UI Properties
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
    private var conversationsArray = [Conversation]() // this is the array that our tableView is going to use to load in all of the objects
    

    // MARK: - System Called Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        createComposeNewMessageButton()
        title = "Conversations"
        addSubviews()
        setupTableView()
        fetchConversations()
        startListeningForConversations()
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
        let vc = ChatViewController(with: recipientEmail, with: fullName)
        vc.title = fullName
        vc.isNewConversation = true
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
    
    /// this is what is going to call the Database getAllConversations and within the event callback which is called everytime there is a change in the conversations we want to then update the tableView here
    private func startListeningForConversations()
    {
        guard let userSafeEmail = standardUserDefaults.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) as? String else {return}
        sharedDatabaseObj.getAllConversations(for: userSafeEmail) {[weak self] result in
            guard let strongSelf = self else {return}
            switch result
            {
            case .success(let conversations):
                guard !conversations.isEmpty else {return}
                strongSelf.conversationsArray = conversations
                print(strongSelf.conversationsArray)
                DispatchQueue.main.async {
                    strongSelf.tableView.isHidden = false
                    strongSelf.tableView.reloadData()
                }
                // we then want to call our ui method that will udpate the tableview and show the updated/new conversations
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
}
//MARK: - Extensions

extension ConversationsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversationsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
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
// stopped at 15:52
