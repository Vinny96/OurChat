//
//  ConversationViewCell.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2022-01-13.
//

import Foundation
import SDWebImage

class ConversationSearchResultCell: UITableViewCell
{
    //MARK: - properties
    static let identifier = "ConversationSearchResultCell"
    
    private let userImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    
    //MARK: - System Functions
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        initializeCellContentFrame()
    }
    
    //MARK: - UI Functions
    private func initializeCellContentFrame()
    {
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 70,
                                     height: 70)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 20,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: 50)
    }
   
    
    
    //MARK: - Functions
    private func initializeCell()
    {
        contentView.addSubviews(views: userImageView, userNameLabel)
        //contentView.addSubview(userImageView)
        //contentView.addSubview(userNameLabel)
        //contentView.addSubview(userMessageLabel)
    }
    
    
    public func configure(with result : SearchResult)
    {
        self.userNameLabel.text = result.fullName
        let path = "images/\(result.email)_profilePicture.jpg"
        print(path)
        StorageManager.shared.getDownloadURL(for: path) {[weak self] result in
            guard let strongSelf = self else {return}
            switch result
            {
            case .success(let downloadURL):
                guard let urlToUse = URL(string: downloadURL) else {return}
                DispatchQueue.main.async {
                    strongSelf.userImageView.sd_setImage(with: urlToUse, completed: nil)
                }
            
            case .failure(let error):
                print("There was an error in getting the sender's downloadURL: \(error)")
            }
        }
    }

    
}
