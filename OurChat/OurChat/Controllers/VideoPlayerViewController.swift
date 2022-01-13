//
//  VideoPlayerViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-09.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    
    // properties
    private var videoURL : URL
    
    
    
    
    // MARK: - System Called Functions and Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "View Video Message"
        view.backgroundColor = .black
        playVideo()
    }
    
    init(videoToUseURL : URL)
    {
        videoURL = videoToUseURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Functions
    private func playVideo()
    {
        let vc = AVPlayerViewController()
        vc.player = AVPlayer(url: videoURL)
        present(vc, animated: true, completion: nil)
    }
}
