//
//  VideoControlsView.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//

import UIKit
import RxSwift
import RxCocoa

class VideoControlsView: UIView {
    
    // UI Elements
    let playPauseButton = IconButton()
    let progressSlider = Slider()
    let currentTimeLabel = TextLabel()
    let durationLabel = TextLabel()
    let activityIndicator = ActivityIndicator()
    
    // Container views for better layout management
    private let topContainer = UIView()
    private let bottomContainer = UIView()
    
    // View Model
    private let viewModel = VideoControlsViewModel()
    private let disposeBag = DisposeBag()
    
    // Input Subjects
    private let isPlayingSubject = PublishSubject<Bool>()
    private let currentTimeSubject = PublishSubject<String>()
    private let durationSubject = PublishSubject<String>()
    private let progressSubject = PublishSubject<Float>()
    private let currentSpeedSubject = PublishSubject<Float>()
    private let isSeekingSubject = PublishSubject<Bool>()
    
    // Output Properties
    var playPauseTapped: ControlEvent<Void> {
        return playPauseButton.rx.tap
    }
    
    var sliderSeekTo: Observable<Float> {
        // 只在拖动结束时发出值
        return progressSlider.rx.controlEvent([.touchUpInside, .touchUpOutside])
            .do(onNext: { [weak self] _ in
                self?.isSeekingSubject.onNext(true)
            })
            .withLatestFrom(progressSlider.rx.value)
    }
    
    var isSliderTracking: Driver<Bool> {
        return output.isSliderTracking
    }
    
    private var output: VideoControlsViewModel.Output!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //         backgroundColor = Design.Colors.overlayBackground
        
        // Configure UI elements
        currentTimeLabel.style = .small
        currentTimeLabel.textAlignment = .center
        
        durationLabel.style = .small
        durationLabel.textAlignment = .center
        
        // Configure containers
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        addSubview(topContainer)
        addSubview(bottomContainer)
        addSubview(activityIndicator)
        
        // Add elements to top container (progress controls)
        topContainer.addSubview(currentTimeLabel)
        topContainer.addSubview(progressSlider)
        topContainer.addSubview(durationLabel)
        
        // Add elements to bottom container (playback controls)
        bottomContainer.addSubview(playPauseButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            topContainer.topAnchor.constraint(equalTo: topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 44),
            
            bottomContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Top container elements
            currentTimeLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: NowUI.Spacing.large),
            currentTimeLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: NowUI.Sizing.labelWidth),
            
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: NowUI.Spacing.small),
            progressSlider.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            
            durationLabel.leadingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: NowUI.Spacing.small),
            durationLabel.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -NowUI.Spacing.large),
            durationLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: NowUI.Sizing.labelWidth),
            
            // Bottom container elements - Play/Pause button centered
            playPauseButton.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: NowUI.Sizing.buttonMedium),
            playPauseButton.heightAnchor.constraint(equalToConstant: NowUI.Sizing.buttonMedium),
            
            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        
        // VideoControlsView.swift
        progressSlider.rx.controlEvent(.touchDown)
            .subscribe(onNext: { _ in
                print("🔍 Touch down event triggered")
            })
            .disposed(by: disposeBag)
        let input = VideoControlsViewModel.Input(
            isPlaying: isPlayingSubject.asObservable(),
            currentTime: currentTimeSubject.asObservable(),
            duration: durationSubject.asObservable(),
            progress: progressSubject.asObservable(),
            playPauseTapped: playPauseButton.rx.tap.asObservable(),
            sliderValueChanged: progressSlider.rx.value.asObservable(),
            sliderTouchBegan: progressSlider.rx.controlEvent(.touchDown).asObservable(),
            sliderTouchEnded: progressSlider.rx.controlEvent([.touchUpInside, .touchUpOutside]).asObservable(),
            isSeeking: isSeekingSubject.asObservable()
        )
        
        output = viewModel.transform(input: input)
        
        // Bind outputs
        output.playPauseButtonImage
            .drive(playPauseButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        output.currentTimeText
            .drive(onNext: { [weak self] text in
                self?.currentTimeLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.durationText
            .drive(onNext: { [weak self] text in
                self?.durationLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.progressValue
            .drive(progressSlider.rx.value)
            .disposed(by: disposeBag)
        
        
        progressSlider.rx.value
            .withLatestFrom(output.isSliderTracking) { value, isTracking in
                return (value, isTracking)
            }
            .filter { (value, isTracking) in isTracking }
            .withLatestFrom(durationSubject) { params, duration in
                return (params.0, duration)
            }
            .subscribe(onNext: { [weak self] value, durationString in
                guard let self = self else { return }
                
                // 将 durationString 转换为秒数
                       let durationComponents = durationString.split(separator: ":").map { Double($0) ?? 0 }
                       let durationSeconds = durationComponents[0] * 60 + durationComponents[1]
                       
                       // 计算预览时间
                       let previewSeconds = Double(value) * durationSeconds
                       let previewTime = self.formatTime(previewSeconds)
                       
                       // 更新时间标签为预览时间
                       self.currentTimeLabel.text = previewTime
            })
            .disposed(by: disposeBag)
    }
    
    // 在 VideoControlsView 类中添加此方法
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // Public methods to update view
    func updatePlayingState(_ isPlaying: Bool) {
        isPlayingSubject.onNext(isPlaying)
    }
    
    func updateTime(current: String, duration: String) {
        print("current",current,"duration",duration)
        currentTimeSubject.onNext(current)
        durationSubject.onNext(duration)
    }
    
    func updateProgress(_ progress: Float) {
        progressSubject.onNext(progress)
    }
    
    func updateSpeed(_ speed: Float) {
        currentSpeedSubject.onNext(speed)
    }
    
    // 提供方法让外部在 seek 完成时调用
    func setSeekingCompleted() {
        isSeekingSubject.onNext(false)
    }
    
    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            playPauseButton.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            playPauseButton.isHidden = false
        }
    }
}
