//
//  CustomVideoPlayerViewController.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//


import UIKit
import AVFoundation

class CustomVideoPlayerViewController: UIViewController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // 自定义UI控件
    private let playPauseButton = UIButton()
    private let progressSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private let controlsContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupVideoPlayer()
        setupUI()
        setupGestures()
        addPlayerObservers()
    }
    
    private func setupVideoPlayer() {
        guard let url = URL(string: "你的视频URL") else { return }
        
        // 创建播放器
        player = AVPlayer(url: url)
        
        // 创建播放器层
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = view.bounds
        
        // 将播放器层添加到视图层
        if let playerLayer = playerLayer {
            view.layer.insertSublayer(playerLayer, at: 0)
        }
    }
    
    private func setupUI() {
        // 设置控制容器
        controlsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsContainer)
        
        // 设置播放/暂停按钮
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        playPauseButton.tintColor = .white
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        controlsContainer.addSubview(playPauseButton)
        
        // 设置进度条
        progressSlider.minimumTrackTintColor = .red
        progressSlider.maximumTrackTintColor = .white.withAlphaComponent(0.5)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        controlsContainer.addSubview(progressSlider)
        
        // 设置时间标签
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = .systemFont(ofSize: 12)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(currentTimeLabel)
        
        durationLabel.textColor = .white
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(durationLabel)
        
        // 添加约束
        NSLayoutConstraint.activate([
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controlsContainer.heightAnchor.constraint(equalToConstant: 80),
            
            playPauseButton.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 16),
            currentTimeLabel.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8),
            progressSlider.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            
            durationLabel.leadingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
        ])
    }
    
    private func setupGestures() {
        // 添加点击手势来显示/隐藏控制
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addPlayerObservers() {
        // 监听播放进度
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            self?.updateTimeLabels(time)
            self?.updateProgressSlider(time)
        }
        
        // 监听播放状态
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
    }
    
    @objc private func playPauseButtonTapped() {
        if player?.rate == 0 {
            player?.play()
            playPauseButton.isSelected = true
        } else {
            player?.pause()
            playPauseButton.isSelected = false
        }
    }
    
    @objc private func sliderValueChanged() {
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(seconds: value, preferredTimescale: 1)
        player?.seek(to: seekTime)
    }
    
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainer.alpha = self.controlsContainer.alpha == 0 ? 1 : 0
        }
    }
    
    private func updateTimeLabels(_ time: CMTime) {
        let currentSeconds = CMTimeGetSeconds(time)
        currentTimeLabel.text = formatTime(currentSeconds)
        
        if let duration = player?.currentItem?.duration {
            let durationSeconds = CMTimeGetSeconds(duration)
            durationLabel.text = formatTime(durationSeconds)
        }
    }
    
    private func updateProgressSlider(_ time: CMTime) {
        guard let duration = player?.currentItem?.duration else { return }
        let currentSeconds = CMTimeGetSeconds(time)
        let durationSeconds = CMTimeGetSeconds(duration)
        progressSlider.value = Float(currentSeconds / durationSeconds)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.currentItem?.status == .readyToPlay {
                // 视频准备好播放
            }
        }
    }
    
    deinit {
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
    }
}