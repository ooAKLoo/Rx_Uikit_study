////
////  VideoPlayerViewController 2.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/5/2.
////
//
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
//        
//        // 设置音频会话，确保即使在静音模式下也能播放声音
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//            print("音频会话设置成功")
//        } catch {
//            print("设置音频会话失败: \(error.localizedDescription)")
//        }
//        
//        setupVideoPlayer()
//    }
//    
//    func setupVideoPlayer() {
//        // 替换为你的服务器地址
//        guard let videoURL = URL(string: "http://192.168.1.18:8080/api/videos/stream/10_1080P.mp4") else {
//            print("无效的URL")
//            return
//        }
//        
//        print("尝试加载视频: \(videoURL.absoluteString)")
//        
//        // 使用AVAsset预加载，这有助于确保音频轨道得到正确识别
//        let asset = AVAsset(url: videoURL)
//        asset.loadValuesAsynchronously(forKeys: ["tracks"]) { [weak self] in
//            guard let self = self else { return }
//            
//            var error: NSError? = nil
//            let status = asset.statusOfValue(forKey: "tracks", error: &error)
//            
//            DispatchQueue.main.async {
//                if status == .loaded {
//                    // 检查并打印音频轨道信息
//                    let audioTracks = asset.tracks(withMediaType: .audio)
//                    print("音频轨道数量: \(audioTracks.count)")
//                    
//                    for (index, track) in audioTracks.enumerated() {
//                        print("音频轨道 \(index): 格式=\(track.formatDescriptions)")
//                    }
//                    
//                    // 创建播放项目
//                    let playerItem = AVPlayerItem(asset: asset)
//                    
//                    // 添加状态监听
//                    self.addPlayerItemObservers(playerItem)
//                    
//                    // 创建播放器
//                    self.player = AVPlayer(playerItem: playerItem)
//                    
//                    // 确保音量已设置
//                    self.player?.volume = 1.0
//                    print("播放器音量设置为: \(self.player?.volume ?? 0)")
//                    
//                    // 创建播放器视图控制器
//                    let playerVC = AVPlayerViewController()
//                    self.playerViewController = playerVC
//                    playerVC.player = self.player
//                    
//                    // 添加为子视图控制器
//                    self.addChild(playerVC)
//                    self.view.addSubview(playerVC.view)
//                    playerVC.view.frame = self.view.bounds
//                    playerVC.didMove(toParent: self)
//                    
//                    // 延迟一秒后尝试播放，给缓冲一些时间
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        self.player?.play()
//                        print("开始播放视频")
//                    }
//                } else {
//                    print("加载视频资源失败: \(error?.localizedDescription ?? "未知错误")")
//                }
//            }
//        }
//        
//        // 添加通知监听
//        addNotificationObservers()
//    }
//    
//    func addPlayerItemObservers(_ playerItem: AVPlayerItem) {
//        // 监听项目是否准备好播放
//        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new, .initial], context: nil)
//        
//        // 监听播放结束
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(playerItemDidReachEnd),
//            name: .AVPlayerItemDidPlayToEndTime,
//            object: playerItem
//        )
//    }
//    
//    func addNotificationObservers() {
//        // 监听播放失败
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(playerItemFailedToPlay),
//            name: .AVPlayerItemFailedToPlayToEndTime,
//            object: nil
//        )
//        
//        // 监听音频路由变化
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(audioRouteChanged),
//            name: AVAudioSession.routeChangeNotification,
//            object: nil
//        )
//        
//        // 监听中断（如来电）
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleInterruption),
//            name: AVAudioSession.interruptionNotification,
//            object: nil
//        )
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == #keyPath(AVPlayerItem.status),
//           let item = object as? AVPlayerItem {
//            let status = AVPlayerItem.Status(rawValue: change?[.newKey] as? Int ?? 0)
//            switch status {
//            case .readyToPlay:
//                print("视频准备好播放")
//                // 检查音频输出
//                if let asset = item.asset as? AVURLAsset {
//                    print("视频URL: \(asset.url.absoluteString)")
//                }
//                // 打印所有轨道
//                item.tracks.forEach { track in
//                    if let assetTrack = track.assetTrack {
//                        print("轨道: \(assetTrack.mediaType.rawValue), 启用: \(track.isEnabled)")
//                    }
//                }
//            case .failed:
//                print("视频加载失败: \(item.error?.localizedDescription ?? "未知错误")")
//            case .unknown:
//                print("视频状态未知")
//            @unknown default:
//                print("未处理的视频状态")
//            }
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//    }
//    
//    @objc func playerItemDidReachEnd(notification: Notification) {
//        print("视频播放完成")
//    }
//    
//    @objc func playerItemFailedToPlay(notification: Notification) {
//        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
//            print("视频播放失败: \(error.localizedDescription)")
//        }
//    }
//    
//    @objc func audioRouteChanged(notification: Notification) {
//        print("音频路由已改变")
//        if let routeChangeReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt {
//            switch routeChangeReason {
//            case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
//                print("新音频设备已连接")
//            case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
//                print("音频设备已断开")
//            default:
//                print("音频路由变更原因: \(routeChangeReason)")
//            }
//        }
//        
//        // 打印当前音频输出
//        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
//        for output in outputs {
//            print("当前音频输出: \(output.portType)")
//        }
//    }
//    
//    @objc func handleInterruption(notification: Notification) {
//        guard let info = notification.userInfo,
//              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
//              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
//            return
//        }
//        
//        switch type {
//        case .began:
//            // 音频被中断
//            print("音频被中断")
//        case .ended:
//            // 中断结束
//            print("音频中断结束")
//            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
//                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
//                if options.contains(.shouldResume) {
//                    // 如果应该恢复播放
//                    player?.play()
//                    print("恢复播放")
//                }
//            }
//        @unknown default:
//            break
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // 暂停播放
//        player?.pause()
//    }
//    
//    deinit {
//        // 移除KVO观察者
//        if let playerItem = player?.currentItem {
//            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
//        }
//        
//        // 移除通知观察者
//        NotificationCenter.default.removeObserver(self)
//        
//        // 停止音频会话
//        try? AVAudioSession.sharedInstance().setActive(false)
//        
//        print("VideoPlayerViewController 已释放")
//    }
//}
