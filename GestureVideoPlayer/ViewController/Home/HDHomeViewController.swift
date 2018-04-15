//
//  ViewController.swift
//  GestureVideoPlayer
//
//  Created by baejji on 2018. 4. 10..
//  Copyright © 2018년 baejji. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

struct VideoData {
    var url: URL
    var imageName: String
}

class HDHomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var videoList: [VideoData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoData: VideoData = VideoData(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, imageName: "thumbnail")
        self.videoList.append(videoData)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDVideoCollectionViewCell", for: indexPath) as! HDVideoCollectionViewCell
        cell.imageView.image = UIImage(named: self.videoList[indexPath.row].imageName)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.videoCollectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let videoViewController: HDVideoPlayerViewController = storyboard.instantiateViewController(withIdentifier: "HDVideoPlayerViewController") as! HDVideoPlayerViewController
        videoViewController.url = videoList[indexPath.row].url
        self.present(videoViewController, animated: true, completion: nil)
    }
    
}

