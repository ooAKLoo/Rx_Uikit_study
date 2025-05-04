////
////  VideoPlayerViewController.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/5/2.
////
//
//import UIKit
//import AVKit
//import AVFoundation
//
//class VideoPlayerViewController: UIViewController {
//    
//    private var player: AVPlayer?
//    private var playerViewController: AVPlayerViewController?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupVideoPlayer()
//    }
//    
//    func setupVideoPlayer() {
//        // 替换为你的服务器地址
//        guard let videoURL = URL(string: "http://192.168.1.18:8080/video/Wallace.Gromit.Vengeance.Most.Fowl.2024.1080p.WEBRip.x265.10bit.AAC.mp4") else {
//            print("无效的URL")
//            return
//        }
//        
//        print("尝试加载视频: \(videoURL.absoluteString)")
//        
//        // 直接使用AVPlayerViewController，避免复杂的KVO
//        let playerVC = AVPlayerViewController()
//        playerViewController = playerVC
//        
//        // 添加通知监听播放错误，而不是KVO
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(playerItemFailedToPlay),
//            name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
//            object: nil
//        )
//        
//        // 添加为子视图控制器
//        addChild(playerVC)
//        view.addSubview(playerVC.view)
//        playerVC.view.frame = view.bounds
//        playerVC.didMove(toParent: self)
//        
//        // 创建播放器
//        player = AVPlayer(url: videoURL)
//        playerVC.player = player
//        
//        // 延迟一秒后尝试播放，给缓冲一些时间
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            self?.player?.play()
//        }
//    }
//    
//    @objc func playerItemFailedToPlay(notification: Notification) {
//        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
//            print("视频播放失败: \(error.localizedDescription)")
//        }
//    }
//    
//    deinit {
//        // 移除通知观察者
//        NotificationCenter.default.removeObserver(self)
//    }
//}
