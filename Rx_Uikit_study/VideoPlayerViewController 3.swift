////
////  VideoPlayerViewController 3.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/5/3.
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
//    private var playerLayer: AVPlayerLayer?
//    
//    // 自定义UI控件
//    private let playPauseButton = UIButton()
//    private let progressSlider = UISlider()
//    private let currentTimeLabel = UILabel()
//    private let durationLabel = UILabel()
//    private let controlsContainer = UIView()
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
//    
//    // 添加时间观察器
//    private var timeObserver: Any?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .black
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
//        setupUI()
//        setupVideoPlayer()
//    }
//    
//    func setupUI() {
//        // 设置活动指示器
//        activityIndicator.color = .white
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(activityIndicator)
//        
//        // 设置控制容器
//        controlsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(controlsContainer)
//        
//        // 设置播放/暂停按钮
//        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .selected)
//        playPauseButton.tintColor = .white
//        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
//        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
//        controlsContainer.addSubview(playPauseButton)
//        
//        // 设置进度条
//        progressSlider.minimumTrackTintColor = .red
//        progressSlider.maximumTrackTintColor = .white.withAlphaComponent(0.5)
//        progressSlider.translatesAutoresizingMaskIntoConstraints = false
//        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
//        controlsContainer.addSubview(progressSlider)
//        
//        // 设置时间标签
//        currentTimeLabel.textColor = .white
//        currentTimeLabel.font = .systemFont(ofSize: 12)
//        currentTimeLabel.text = "00:00"
//        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        controlsContainer.addSubview(currentTimeLabel)
//        
//        durationLabel.textColor = .white
//        durationLabel.font = .systemFont(ofSize: 12)
//        durationLabel.text = "00:00"
//        durationLabel.translatesAutoresizingMaskIntoConstraints = false
//        controlsContainer.addSubview(durationLabel)
//        
//        // 添加约束
//        NSLayoutConstraint.activate([
//            // 活动指示器
//            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            
//            // 控制容器
//            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            controlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            controlsContainer.heightAnchor.constraint(equalToConstant: 80),
//            
//            // 播放按钮
//            playPauseButton.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
//            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
//            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
//            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            // 当前时间标签
//            currentTimeLabel.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 16),
//            currentTimeLabel.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
//            currentTimeLabel.widthAnchor.constraint(equalToConstant: 50),
//            
//            // 进度条
//            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8),
//            progressSlider.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
//            
//            // 持续时间标签
//            durationLabel.leadingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: 8),
//            durationLabel.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
//            durationLabel.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
//            durationLabel.widthAnchor.constraint(equalToConstant: 50),
//        ])
//        
//        // 添加点击手势来显示/隐藏控制
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        view.addGestureRecognizer(tapGesture)
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
//        activityIndicator.startAnimating()
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
//                    // 创建播放器层
//                    self.playerLayer = AVPlayerLayer(player: self.player)
//                    self.playerLayer?.videoGravity = .resizeAspect
//                    self.playerLayer?.frame = self.view.bounds
//                    
//                    // 将播放器层添加到视图层
//                    if let playerLayer = self.playerLayer {
//                        self.view.layer.insertSublayer(playerLayer, at: 0)
//                    }
//                    
//                    // 确保音量已设置
//                    self.player?.volume = 1.0
//                    print("播放器音量设置为: \(self.player?.volume ?? 0)")
//                    
//                    // 添加时间观察器
//                    self.addTimeObserver()
//                    
//                    // 延迟一秒后尝试播放，给缓冲一些时间
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        self.activityIndicator.stopAnimating()
//                        self.player?.play()
//                        self.playPauseButton.isSelected = true
//                        print("开始播放视频")
//                    }
//                } else {
//                    self.activityIndicator.stopAnimating()
//                    print("加载视频资源失败: \(error?.localizedDescription ?? "未知错误")")
//                }
//            }
//        }
//        
//        // 添加通知监听
//        addNotificationObservers()
//    }
//    
//    func addTimeObserver() {
//        // 每0.1秒更新一次UI
//        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
//            self?.updateTimeLabels(time)
//            self?.updateProgressSlider(time)
//        }
//    }
//    
//    func updateTimeLabels(_ time: CMTime) {
//        let currentSeconds = CMTimeGetSeconds(time)
//        currentTimeLabel.text = formatTime(currentSeconds)
//        
//        if let duration = player?.currentItem?.duration, duration.isNumeric {
//            let durationSeconds = CMTimeGetSeconds(duration)
//            durationLabel.text = formatTime(durationSeconds)
//        }
//    }
//    
//    func updateProgressSlider(_ time: CMTime) {
//        guard let duration = player?.currentItem?.duration, duration.isNumeric else { return }
//        let currentSeconds = CMTimeGetSeconds(time)
//        let durationSeconds = CMTimeGetSeconds(duration)
//        
//        if durationSeconds > 0 {
//            progressSlider.value = Float(currentSeconds / durationSeconds)
//        }
//    }
//    
//    func formatTime(_ seconds: Double) -> String {
//        let mins = Int(seconds) / 60
//        let secs = Int(seconds) % 60
//        return String(format: "%02d:%02d", mins, secs)
//    }
//    
//    @objc func playPauseButtonTapped() {
//        if player?.rate == 0 {
//            player?.play()
//            playPauseButton.isSelected = true
//        } else {
//            player?.pause()
//            playPauseButton.isSelected = false
//        }
//    }
//    
//    @objc func sliderValueChanged() {
//        guard let duration = player?.currentItem?.duration, duration.isNumeric else { return }
//        let value = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
//        let seekTime = CMTime(seconds: value, preferredTimescale: 1)
//        
//        player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
//    }
//    
//    @objc func handleTap() {
//        UIView.animate(withDuration: 0.3) {
//            self.controlsContainer.alpha = self.controlsContainer.alpha == 0 ? 1 : 0
//        }
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
//                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
//                }
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
//        playPauseButton.isSelected = false
//        // 可选：重置到开始位置
//        player?.seek(to: .zero)
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
//                    playPauseButton.isSelected = true
//                    print("恢复播放")
//                }
//            }
//        @unknown default:
//            break
//        }
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        playerLayer?.frame = view.bounds
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // 暂停播放
//        player?.pause()
//        playPauseButton.isSelected = false
//    }
//    
//    deinit {
//        // 移除时间观察器
//        if let observer = timeObserver {
//            player?.removeTimeObserver(observer)
//        }
//        
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
