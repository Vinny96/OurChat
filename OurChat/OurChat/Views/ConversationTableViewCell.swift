//
//  ConversationTableViewCell.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-09-20.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell
{
    //MARK: - properties
    static let identifier = "ConverstationTableViewCell"
    
    private let userImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
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
                                     width: 100,
                                     height: 100)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height - 20) / 2)
    }
   
    
    
    //MARK: - Functions
    private func initializeCell()
    {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    
    public func configure(with model : Conversation)
    {
        self.userNameLabel.text = model.otherUserName
        self.userMessageLabel.text = model.latestMessage.message
        let path = "images/\(model.otherUserEmail)_profilePicture.jpg"
        print(path)
        StorageManager.shared.getDownloadURL(for: path) {[weak self] result in
            guard let strongSelf = self else {return}
            switch result
            {
            case .success(let downloadURL):
                print("Successfully got the downloadURL for the sender.")
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
