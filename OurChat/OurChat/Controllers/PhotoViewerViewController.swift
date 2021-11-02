//
//  PhotoViewerViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

    //MARK: -Properties
    private let imageView : UIImageView = {
        let imageViewToReturn = UIImageView()
        imageViewToReturn.contentMode = .scaleAspectFill
        imageViewToReturn.clipsToBounds = true
        return imageViewToReturn
    }()
    
    private var url : URL
    
    
    //MARK: - Initializers and System Called Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        initializeImageView()
        displayImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubviews(views: imageView)
    }
    
    init(urlToUse : URL)
    {
        url = urlToUse
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Functions
    private func initializeImageView()
    {
        imageView.frame = view.bounds
    }
    
    private func displayImage()
    {
        print("Image should be displayed now")
        imageView.sd_setImage(with: url, completed: nil)
    }
    
}
