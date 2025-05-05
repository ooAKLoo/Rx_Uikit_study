//
//  VideoPlayerViewModel 2.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class VideoPlayerViewModel {
    
    // MARK: - Types
    
    enum UserAction {
        case playPause
        case seek(Float)
        case seekByOffset(Double)
        case adjustSpeed(Float)
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let userAction: Observable<UserAction>
    }
    
    struct Output {
        let playerState: Driver<PlayerState>
        let error: Driver<String?>
        let seekCompleted: Driver<Void>
    }
    
    struct PlayerState {
        let player: AVPlayer?
        let isPlaying: Bool
        let isLoading: Bool
        let currentTime: String
        let duration: String
        let progress: Float
    }
    
    // MARK: - Properties
    
    private let videoMetadata: VideoMetadata
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(videoMetadata: VideoMetadata) {
        self.videoMetadata = videoMetadata
    }
    
    // MARK: - Transformation
    
    func transform(input: Input) -> Output {
        let playerRelay = BehaviorRelay<AVPlayer?>(value: nil)
        let isPlayingRelay = BehaviorRelay<Bool>(value: false)
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = BehaviorRelay<String?>(value: nil)
        let seekCompletedRelay = PublishRelay<Void>()
        
        setupAudioSession()
        
        // Handle view lifecycle
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.loadVideo(
                    player: playerRelay,
                    isLoading: isLoadingRelay,
                    error: errorRelay,
                    isPlaying: isPlayingRelay
                )
            })
            .disposed(by: disposeBag)
        
        input.viewWillDisappear
            .withLatestFrom(playerRelay)
            .subscribe(onNext: { player in
                player?.pause()
                isPlayingRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        // Handle user actions
        input.userAction
            .withLatestFrom(playerRelay) { action, player in (action, player) }
            .subscribe(onNext: { [weak self] action, player in
                self?.handleUserAction(
                    action,
                    player: player,
                    isPlaying: isPlayingRelay,
                    seekCompleted: seekCompletedRelay
                )
            })
            .disposed(by: disposeBag)
        
        // Create player state observable
        let playerState = createPlayerStateObservable(
            player: playerRelay,
            isPlaying: isPlayingRelay,
            isLoading: isLoadingRelay
        )
        
        // Handle playback end
        NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime)
            .subscribe(onNext: { _ in
                isPlayingRelay.accept(false)
                playerRelay.value?.seek(to: .zero)
            })
            .disposed(by: disposeBag)
        
        return Output(
            playerState: playerState,
            error: errorRelay.asDriver(),
            seekCompleted: seekCompletedRelay.asDriver(onErrorJustReturn: ())
        )
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error.localizedDescription)")
        }
    }
    
    private func loadVideo(
        player: BehaviorRelay<AVPlayer?>,
        isLoading: BehaviorRelay<Bool>,
        error: BehaviorRelay<String?>,
        isPlaying: BehaviorRelay<Bool>
    ) {
        isLoading.accept(true)
        
        let playerItem = AVPlayerItem(url: videoMetadata.videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.volume = 1.0
        
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
    
    private func handleUserAction(
        _ action: UserAction,
        player: AVPlayer?,
        isPlaying: BehaviorRelay<Bool>,
        seekCompleted: PublishRelay<Void>
    ) {
        guard let player = player else { return }
        
        switch action {
        case .playPause:
            if player.rate == 0 {
                player.play()
                isPlaying.accept(true)
            } else {
                player.pause()
                isPlaying.accept(false)
            }
            
        case .seek(let progress):
            seekToProgress(progress, player: player, seekCompleted: seekCompleted)
            
        case .seekByOffset(let offset):
            seekByOffset(offset, player: player)
            
        case .adjustSpeed(let speed):
            player.rate = speed
        }
    }
    
    private func seekToProgress(_ progress: Float, player: AVPlayer, seekCompleted: PublishRelay<Void>) {
        guard let duration = player.currentItem?.duration,
              duration.isNumeric else { return }
        
        let value = Float64(progress) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(seconds: value, preferredTimescale: PlayerConfiguration.Video.seekTimescale)
        
        player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
            seekCompleted.accept(())
        }
    }
    
    private func seekByOffset(_ offset: Double, player: AVPlayer) {
        let currentTime = player.currentTime()
        let currentSeconds = CMTimeGetSeconds(currentTime)
        let newSeconds = max(0, currentSeconds + offset)
        
        if let duration = player.currentItem?.duration, duration.isNumeric {
            let durationSeconds = CMTimeGetSeconds(duration)
            let finalSeconds = min(newSeconds, durationSeconds)
            let seekTime = CMTime(seconds: finalSeconds, preferredTimescale: PlayerConfiguration.Video.seekTimescale)
            player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
    private func createPlayerStateObservable(
        player: BehaviorRelay<AVPlayer?>,
        isPlaying: BehaviorRelay<Bool>,
        isLoading: BehaviorRelay<Bool>
    ) -> Driver<PlayerState> {
        let timeObservable = player
            .compactMap { $0 }
            .flatMapLatest { player -> Observable<CMTime> in
                Observable<Int>.interval(
                    .milliseconds(Int(PlayerConfiguration.Video.timeObserverInterval * 1000)),
                    scheduler: MainScheduler.instance
                )
                .compactMap { _ in player.currentTime() }
            }
            .share(replay: 1)
        
        return Observable.combineLatest(
            player,
            isPlaying,
            isLoading,
            timeObservable
        )
        .map { [weak self] player, isPlaying, isLoading, currentTime in
            let currentSeconds = CMTimeGetSeconds(currentTime)
            let durationSeconds = self?.videoMetadata.duration ?? 0
            let progress = durationSeconds > 0 ? Float(currentSeconds / durationSeconds) : 0
            
            return PlayerState(
                player: player,
                isPlaying: isPlaying,
                isLoading: isLoading,
                currentTime: self?.formatTime(currentSeconds) ?? "00:00",
                duration: self?.videoMetadata.durationFormatted ?? "00:00",
                progress: progress
            )
        }
        .asDriver(onErrorJustReturn: PlayerState(
            player: nil,
            isPlaying: false,
            isLoading: false,
            currentTime: "00:00",
            duration: "00:00",
            progress: 0
        ))
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}