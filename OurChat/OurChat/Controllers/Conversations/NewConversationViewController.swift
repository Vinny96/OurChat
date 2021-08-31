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
    
    
    
    
    // System functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeVC()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    
    
    
    
    
    // MARK: - Functions
    private func initializeVC()
    {
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        searchBar.becomeFirstResponder() 
    }
    
    // MARK: - OBJC Functions
    @objc private func didTapCancel()
    {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension NewConversationViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search bar button pressed")
    }
    
}
