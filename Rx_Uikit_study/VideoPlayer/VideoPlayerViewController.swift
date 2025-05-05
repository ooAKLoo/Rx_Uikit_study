//
//  VideoPlayerViewController.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import MediaPlayer

class VideoPlayerViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let videoRenderView = VideoRenderView()
    private let controlsView = VideoControlsView()
    
    private lazy var volumeView: MPVolumeView = {
        let view = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 100, height: 100))
        view.showsVolumeSlider = true
        view.alpha = 0.00001
        return view
    }()
    
    // Indicators
    private let speedIndicatorLabel = IndicatorLabel()
    private let progressIndicatorLabel = IndicatorLabel()
    private let brightnessIndicatorLabel = IndicatorLabel()
    private let volumeIndicatorLabel = IndicatorLabel()
    
    // MARK: - Properties
    
    private let playerViewModel: VideoPlayerViewModel
    private let gestureHandler = VideoGestureHandler()
    private lazy var indicatorManager = IndicatorManager(
        speedIndicator: speedIndicatorLabel,
        progressIndicator: progressIndicatorLabel,
        brightnessIndicator: brightnessIndicatorLabel,
        volumeIndicator: volumeIndicatorLabel
    )
    
    // Rx
    private let disposeBag = DisposeBag()
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let viewWillDisappearSubject = PublishSubject<Void>()
    private let userActionSubject = PublishSubject<VideoPlayerViewModel.UserAction>()
    
    // MARK: - Initialization
    
    init(videoMetadata: VideoMetadata) {
        self.playerViewModel = VideoPlayerViewModel(videoMetadata: videoMetadata)
        super.init(nibName: nil, bundle: nil)
        self.gestureHandler.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        bindViewModel()
        viewDidLoadSubject.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearSubject.onNext(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoRenderView.setNeedsLayout()
    }
}

// MARK: - Setup Methods

extension VideoPlayerViewController {
    
    private func setupUI() {
        view.backgroundColor = .black
        
        videoRenderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoRenderView)
        
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsView)
        
        view.addSubview(speedIndicatorLabel)
        view.addSubview(progressIndicatorLabel)
        view.addSubview(brightnessIndicatorLabel)
        view.addSubview(volumeIndicatorLabel)
        view.addSubview(volumeView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            videoRenderView.topAnchor.constraint(equalTo: view.topAnchor),
            videoRenderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoRenderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoRenderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // controlsView 现在覆盖整个视图
            controlsView.topAnchor.constraint(equalTo: view.topAnchor),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            speedIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speedIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            progressIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            brightnessIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brightnessIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            volumeIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        let gestures = gestureHandler.setupGestures(on: view)
        gestures.forEach { view.addGestureRecognizer($0) }
    }
    
    private func bindViewModel() {
        let input = VideoPlayerViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            viewWillDisappear: viewWillDisappearSubject.asObservable(),
            userAction: Observable.merge(
                userActionSubject.asObservable(),
                controlsView.playPauseTapped.map { .playPause },
                controlsView.sliderSeekTo.map { .seek($0) },
                controlsView.speedSelected.map { .setSpeed($0) }  // 添加这一行
            )
        )
        
        let output = playerViewModel.transform(input: input)
        
        output.playerState
            .drive(onNext: { [weak self] state in
                self?.updateUI(with: state)
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                guard let error = error else { return }
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        output.seekCompleted
            .drive(onNext: { [weak self] _ in
                self?.controlsView.setSeekingCompleted()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with state: VideoPlayerViewModel.PlayerState) {
        videoRenderView.setPlayer(state.player)
        controlsView.updatePlayingState(state.isPlaying)
        controlsView.setLoading(state.isLoading)
        controlsView.updateTime(current: state.currentTime, duration: state.duration)
        controlsView.updateProgress(state.progress)
        controlsView.updateSpeed(state.speed)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - GestureHandlerDelegate

extension VideoPlayerViewController: GestureHandlerDelegate {
    func didUpdateSeekOffset(_ offset: Double) {
        // 实时显示进度indicator
        indicatorManager.showProgressIndicator(offset: offset)
    }
    
    func didRequestSeek(offset: Double) {
        // 执行实际的seek操作
        userActionSubject.onNext(.seekByOffset(offset))
        // 不需要在这里显示indicator了，因为已经在didUpdateSeekOffset中显示
    }
    
    
    func didUpdateSpeed(_ speed: Float) {
        userActionSubject.onNext(.adjustSpeed(speed))
        indicatorManager.showSpeedIndicator(speed: speed)
    }
    
    func didUpdateBrightness(_ brightness: Float) {
        indicatorManager.showBrightnessIndicator(brightness: brightness)
    }
    
    func didUpdateVolume(_ volume: Float) {
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.async {
                slider.value = volume
            }
        }
        indicatorManager.showVolumeIndicator(volume: volume)
    }
    
    func didTogglePlayPause() {
        userActionSubject.onNext(.playPause)
    }
    
//    func didToggleControls() {
//        UIView.animate(withDuration: PlayerConfiguration.UI.controlsAnimationDuration) {
//            self.controlsView.alpha = self.controlsView.alpha == 0 ? 1 : 0
//        }
//        
//        // 假设这在一个ViewController中
////        setupTapToDismiss(for: speedMenuView as! SelectMenuView<Any>, excluding: [speedButton])
//    }
    
    func didToggleControls() {
        UIView.animate(withDuration: PlayerConfiguration.UI.controlsAnimationDuration) {
            self.controlsView.alpha = self.controlsView.alpha == 0 ? 1 : 0
        } completion: { finished in
            // 如果控制面板被隐藏，确保速度菜单也隐藏
            if self.controlsView.alpha == 0 {
                self.controlsView.speedMenuView.hideMenu()
            }
        }
    }
    
    func didUpdateSpeedWithoutIndicator(_ speed: Float) {
        userActionSubject.onNext(.adjustSpeed(speed))
        // 不显示指示器
    }
    
    func didEndGestureAdjustment(_ gestureType: VideoGestureHandler.GestureType) {
        switch gestureType {
        case .speed:
            indicatorManager.hideIndicator(.speed)
        case .brightness:
            indicatorManager.hideIndicator(.brightness)
        case .volume:
            indicatorManager.hideIndicator(.volume)
        case .seek:
            indicatorManager.hideIndicator(.progress)
        case .none:
            break
        }
    }
    
    func didStartSpeedAdjustment(initialSpeed: Float) {
        // 1. 先隐藏控制视图
        UIView.animate(withDuration: PlayerConfiguration.UI.indicatorShowDuration) {
            self.controlsView.alpha = 0
        } completion: { _ in
            // 2. 控制视图完全隐藏后，再显示速度指示器
            self.userActionSubject.onNext(.adjustSpeed(initialSpeed))
            self.indicatorManager.showSpeedIndicator(speed: initialSpeed)
            self.controlsView.speedMenuView.hideMenu()
        }
    }
    
    func didBeginGesture(_ gestureType: VideoGestureHandler.GestureType) {
        // 确保速度菜单隐藏
        controlsView.speedMenuView.hideMenu()
    }
}
