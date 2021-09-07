//
//  NewConversationViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    // properties
    public var completion : (([String : String]) -> (Void))?
    
    
    private var databaseObject = DatabaseManager.shared
    private var arrayOfUsers : [[String : String]] = [[String : String]]()
    private var arrayOfFilteredUsers : [[String : String]] = [[String : String]]()
    private var hasFetched = false
    private var standardUserDefaults = UserDefaults.standard
    private let spinner = JGProgressHUD()
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel : UILabel = {
        let noResultsLabel = UILabel()
        noResultsLabel.isHidden = true
        noResultsLabel.text = "No Results"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .green
        noResultsLabel.font = .systemFont(ofSize: 21, weight: .medium)
        return noResultsLabel
    }()
    
    
    
    
    // MARK: - System functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeVC()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeTableView()
        initalizeNoResultsLabel()
    }
    
    //MARK: - UI Functions
    
    private func initializeTableView()
    {
        tableView.frame = view.bounds
    }
    
    private func initalizeNoResultsLabel()
    {
        noResultsLabel.frame = CGRect(x: view.width / 4, y: (view.height - 200) / 2, width: view.width / 2 , height: 200)
    }
    
    // MARK: - Functions
    private func initializeVC()
    {
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        addSubViews()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func addSubViews()
    {
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
    }
    
    private func filterUsers(with term : String)
    {
        guard hasFetched == true else {return}
        
        let results : [[String : String]] = self.arrayOfUsers.filter {
            guard let name = $0["full_name"]?.lowercased() else {
                return false
            }
            
            // success
            return name.hasPrefix(term.lowercased())
        }
        self.arrayOfFilteredUsers = results
        print("-------------------")
        print(arrayOfFilteredUsers)
    }
    
    private func updateUI()
    {
        spinner.dismiss()
        if(arrayOfFilteredUsers.count == 0)
        {
            
           // spinner.dismiss()
            noResultsLabel.isHidden = false
            tableView.isHidden = true 
        }
        else
        {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    
    // MARK: - OBJC Functions
    @objc private func didTapCancel()
    {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension NewConversationViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text else {
            // here this means there is nothing in the search bar so we can just return
            return
        }
        
        if text.replacingOccurrences(of: " ", with: "").isEmpty == false
        {
            arrayOfFilteredUsers.removeAll() // we want to empty the results array prior to every search so we dont have old results in with the new results
            spinner.show(in: view)
            // so this means that there are alphanumeric character(s) in the search bar that we can search for
            self.searchUsers(query: text)
            
        }
    }
    
    func searchUsers(query : String)
    {
        // check if we have fetched
        // if it does we filter
        // if it does not we then fetch all the users from firebase
        
        if hasFetched
        {
            // we filter
            filterUsers(with: query)
            updateUI()
        }
        else
        {
            // we fetch then filter
            databaseObject.getAllUsersFromDB {[weak self] result in
                guard let strongSelf = self else{return}
                switch result
                {
                case .success(let allUsers):
                    print(allUsers)
                    strongSelf.arrayOfUsers = allUsers
                    strongSelf.hasFetched = true
                    strongSelf.filterUsers(with: query)
                    strongSelf.updateUI()
                    break
                
                case .failure(let error):
                    print("Failed to get all the users from database from NewConversations: \(error)")
                    return
                }
            }
        }
    }
}

extension NewConversationViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUserData = arrayOfFilteredUsers[indexPath.row]
        dismiss(animated: true) {[weak self] in
            guard let strongSelf = self else{return}
            strongSelf.completion?(targetUserData)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfFilteredUsers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Running here ")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrayOfFilteredUsers[indexPath.row]["full_name"]
        return cell
    }
    
    
    
}
