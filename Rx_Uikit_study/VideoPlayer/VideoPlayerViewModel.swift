//
//  VideoPlayerViewModel.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class VideoPlayerViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let playPauseTapped: Observable<Void>
        let seekTo: Observable<Float>
        let viewWillDisappear: Observable<Void>
        let longPressBegan: Observable<Void>
        let longPressEnded: Observable<Void>
        let seekByOffset: Observable<Double>
    }
    
    struct Output {
        let player: Driver<AVPlayer?>
        let isPlaying: Driver<Bool>
        let currentTime: Driver<String>
        let duration: Driver<String>
        let progress: Driver<Float>
        let isLoading: Driver<Bool>
        let error: Driver<String?>
        let seekCompleted: Driver<Void>
    }
    
    private let videoMetadata: VideoMetadata
    private let disposeBag = DisposeBag()
    
    init(videoMetadata: VideoMetadata) {
        self.videoMetadata = videoMetadata
    }
    
    func transform(input: Input) -> Output {
        // Internal state
        let player = BehaviorRelay<AVPlayer?>(value: nil)
        let isPlayingRelay = BehaviorRelay<Bool>(value: false)
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = BehaviorRelay<String?>(value: nil)
        let seekCompletedRelay = PublishRelay<Void>()
        
        // Setup audio session
        setupAudioSession()
        
        // Handle view did load
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.loadVideo(player: player, isLoading: isLoadingRelay, error: errorRelay, isPlaying: isPlayingRelay)
            })
            .disposed(by: disposeBag)
        
        // Handle play/pause
        input.playPauseTapped
            .withLatestFrom(player)
            .subscribe(onNext: { currentPlayer in
                guard let currentPlayer = currentPlayer else { return }
                if currentPlayer.rate == 0 {
                    currentPlayer.play()
                    isPlayingRelay.accept(true)
                } else {
                    currentPlayer.pause()
                    isPlayingRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        // Handle seek
        input.seekTo
            .withLatestFrom(player) { progress, currentPlayer in
                (progress, currentPlayer)
            }
            .subscribe(onNext: { progress, currentPlayer in
                guard let currentPlayer = currentPlayer,
                      let duration = currentPlayer.currentItem?.duration,
                      duration.isNumeric else { return }
                
                let value = Float64(progress) * CMTimeGetSeconds(duration)
                let seekTime = CMTime(seconds: value, preferredTimescale: 600)
                
                // 添加日志
                print("🎯 Seeking to: \(value) seconds (progress: \(progress))")
                
                
                currentPlayer.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                    seekCompletedRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        // Handle seek by offset (左滑右滑)
        input.seekByOffset
            .withLatestFrom(player) { offset, currentPlayer in
                (offset, currentPlayer)
            }
            .subscribe(onNext: { offset, currentPlayer in
                guard let currentPlayer = currentPlayer else { return }
                
                let currentTime = currentPlayer.currentTime()
                let currentSeconds = CMTimeGetSeconds(currentTime)
                let newSeconds = currentSeconds + offset
                
                // 确保不会seek到负数
                let clampedSeconds = max(0, newSeconds)
                
                // 检查是否超过视频长度
                if let duration = currentPlayer.currentItem?.duration,
                   duration.isNumeric {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    let finalSeconds = min(clampedSeconds, durationSeconds)
                    
                    let seekTime = CMTime(seconds: finalSeconds, preferredTimescale: 600)
                    currentPlayer.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                } else {
                    let seekTime = CMTime(seconds: clampedSeconds, preferredTimescale: 600)
                    currentPlayer.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            })
            .disposed(by: disposeBag)
        
        // Handle view will disappear
        input.viewWillDisappear
            .withLatestFrom(player)
            .subscribe(onNext: { currentPlayer in
                currentPlayer?.pause()
                isPlayingRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        // Handle long press for speed control
        input.longPressBegan
            .withLatestFrom(player)
            .subscribe(onNext: { currentPlayer in
                guard let currentPlayer = currentPlayer else { return }
                // 长按时设置2倍速播放
                currentPlayer.rate = 2.0
            })
            .disposed(by: disposeBag)
        
        input.longPressEnded
            .withLatestFrom(player)
            .withLatestFrom(isPlayingRelay) { player, isPlaying in
                (player, isPlaying)
            }
            .subscribe(onNext: { currentPlayer, isPlaying in
                guard let currentPlayer = currentPlayer else { return }
                // 松开时恢复正常播放速度
                if isPlaying {
                    currentPlayer.rate = 1.0
                } else {
                    currentPlayer.rate = 0.0
                }
            })
            .disposed(by: disposeBag)
        
        // 在 timeObservable 中添加调试
        let timeObservable = player
            .compactMap { $0 }
            .flatMapLatest { currentPlayer -> Observable<CMTime> in
                return Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance)
                    .compactMap { _ in
                        let time = currentPlayer.currentTime()
                        return time
                    }
            }
            .share(replay: 1)
        
        let currentTime = timeObservable
            .map { [weak self] time -> String in
                let seconds = CMTimeGetSeconds(time)
                let formatted = self?.formatTime(seconds) ?? "00:00"
                return formatted
            }
            .asDriver(onErrorJustReturn: "00:00")
        
        let duration = Driver.just(videoMetadata.durationFormatted)
        
        let progress = timeObservable
            .map { [weak self] currentTime -> Float in
                guard let self = self else { return 0 }
                
                let currentSeconds = CMTimeGetSeconds(currentTime)
                let durationSeconds = self.videoMetadata.duration
                return durationSeconds > 0 ? Float(currentSeconds / durationSeconds) : 0
            }
            .asDriver(onErrorJustReturn: 0)
        
        // Listen for playback end
        NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime)
            .subscribe(onNext: { [weak isPlayingRelay, weak player] _ in
                isPlayingRelay?.accept(false)
                player?.value?.seek(to: .zero)
            })
            .disposed(by: disposeBag)
        
        return Output(
            player: player.asDriver(),
            isPlaying: isPlayingRelay.asDriver(),
            currentTime: currentTime,
            duration: duration,
            progress: progress,
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asDriver(),
            seekCompleted: seekCompletedRelay.asDriver(onErrorJustReturn: ())
        )
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error.localizedDescription)")
        }
    }
    
    private func loadVideo(player: BehaviorRelay<AVPlayer?>, isLoading: BehaviorRelay<Bool>, error: BehaviorRelay<String?>, isPlaying: BehaviorRelay<Bool>) {
        isLoading.accept(true)
        
        // 直接使用元数据中的URL加载视频
        let playerItem = AVPlayerItem(url: videoMetadata.videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.volume = 1.0
        
        // 监听播放器状态
        playerItem.rx.observeWeakly(AVPlayerItem.Status.self, "status")
            .subscribe(onNext: { status in
                if status == .readyToPlay {
                    isLoading.accept(false)
                    newPlayer.play()
                    isPlaying.accept(true)
                } else if status == .failed {
                    isLoading.accept(false)
                    error.accept(playerItem.error?.localizedDescription ?? "播放失败")
                }
            })
            .disposed(by: disposeBag)
        
        player.accept(newPlayer)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
