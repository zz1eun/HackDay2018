//
//  HDVideoPlayerViewController.swift
//  GestureVideoPlayer
//
//  Created by baejji on 2018. 4. 11..
//  Copyright © 2018년 baejji. All rights reserved.
//

import UIKit
import AVFoundation

class HDVideoPlayerViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var topControllerView: UIView!
    @IBOutlet weak var bottomControllerView: UIView!
    
    var player: AVPlayer!
    var audioPlayer: AVAudioPlayer!
    var playerLayer: AVPlayerLayer!
    var url: URL!
    var isVideoPlaying: Bool = true
    var isControllerViewHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createVideoPlayer()
        self.addTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.player.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.playerLayer.frame = self.videoView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    //MARK: Create View
    
    func createVideoPlayer() {
        self.player = AVPlayer(url: self.url)
        self.player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        self.addObserver()
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = .resize
        
        self.videoView.layer.addSublayer(self.playerLayer)
        
        self.audioPlayer = AVAudioPlayer()
    }
    
    //MARK: Private Method
    
    func addTapGesture() {
        let singleTapVideoView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        singleTapVideoView.numberOfTapsRequired = 1
        self.videoView.addGestureRecognizer(singleTapVideoView)
        
        let doubleTapVideoView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapVideoView.numberOfTapsRequired = 2
        self.videoView.addGestureRecognizer(doubleTapVideoView)
        
        singleTapVideoView.require(toFail: doubleTapVideoView)
        
        let panVideoView: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panVideoView(gesture:)))
        self.videoView.addGestureRecognizer(panVideoView)
        
    }
    
    func addObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        _ = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            
            if currentItem.status == .readyToPlay {
                self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            }
            self?.timeSlider.minimumValue = 0.0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(time: currentItem.currentTime())
        })
    }
    
    func getTimeString(time: CMTime) -> String {
        let totalSecond = CMTimeGetSeconds(time)
        let hours: Int = Int(totalSecond/3600)
        let minutes: Int = Int(totalSecond/60) % 60
        let second: Int = Int(totalSecond.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours, minutes, second])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, second])
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = self.player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLabel.text = self.getTimeString(time: self.player.currentItem!.duration)
        }
    }
    
    //MARK: ABAtion
    
    @IBAction func touchPlayButton(_ sender: UIButton) {
        if self.isVideoPlaying {
            self.player.pause()
            sender.setTitle("Play", for: .normal)
        } else {
            self.player.play()
            sender.setTitle("Pause", for: .normal)
        }
        
        self.isVideoPlaying = !self.isVideoPlaying
    }
    
    @IBAction func touchForwardButton(_ sender: UIButton) {
        guard let duration = self.player.currentItem?.duration else {return}
        let currentTime = CMTimeGetSeconds(self.player.currentTime())
        let newTime = currentTime + 10.0
        
        if newTime < CMTimeGetSeconds(duration) - 10.0 {
            let time = CMTimeMake(Int64(newTime*1000), 1000)
            self.player.seek(to: time)
        }
    }
    
    @IBAction func touchBackwardButton(_ sender: UIButton) {
        let currentTime = CMTimeGetSeconds(self.player.currentTime())
        var newTime = currentTime - 10.0
        
        if newTime < 0 {
            newTime = 0
        }
        
        let time = CMTimeMake(Int64(newTime*1000), 1000)
        self.player.seek(to: time)
    }
    
    @IBAction func sliderVauleChanged(_ sender: UISlider) {
        self.player.seek(to: CMTimeMake(Int64(sender.value)*1000, 1000))
    }
    
    @IBAction func touchDoneButton(_ sender: UIButton) {
        self.player.pause()
        self.player.currentItem?.removeObserver(self, forKeyPath: "duration")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchLockButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "Lock" {
            
        } else {
            
        }
    }
    
    //MARK: Tap Gesture
    
    @objc func singleTap() {
        if self.isControllerViewHidden {
            self.topControllerView.alpha = 1.0
            self.bottomControllerView.alpha = 1.0
        } else {
            self.topControllerView.alpha = 0.0
            self.bottomControllerView.alpha = 0.0
        }

        self.isControllerViewHidden = !self.isControllerViewHidden
    }
    
    @objc func doubleTap() {
        if self.playerLayer.videoGravity == .resize {
            self.playerLayer.videoGravity = .resizeAspectFill
        } else {
            self.playerLayer.videoGravity = .resize
        }
    }
    
    @objc func panVideoView(gesture: UIPanGestureRecognizer) {
        let velocity: CGPoint = gesture.velocity(in: self.videoView)
        let location: CGPoint = gesture.location(in: self.videoView)
        
        if location.x < self.videoView.frame.midX {
            if velocity.y > 0 {
                if UIScreen.main.brightness > 0.1 {
                    UIScreen.main.brightness -= 0.1
                }
            } else {
                if UIScreen.main.brightness < 1.0 {
                    UIScreen.main.brightness += 0.1
                }
            }
        } else {
            if velocity.y > 0 {
                if self.player.volume > 0.1 {
                    self.player.volume -= 0.1
                }
                
            } else {
                if self.player.volume < 1.0 {
                    self.player.volume += 0.1
                }
            }
        }
    }
    
}
