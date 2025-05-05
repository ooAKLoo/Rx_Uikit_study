//
//  VideoControlsView 2.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/5.
//

import UIKit
import RxSwift
import RxCocoa

class VideoControlsView: UIView {
    
    // UI Elements
    let playPauseButton = IconButton()
    let speedButton = TextButton()
    let progressSlider = Slider()
    let currentTimeLabel = TextLabel()
    let durationLabel = TextLabel()
    let activityIndicator = ActivityIndicator()
    
    // 倍速选择菜单
    let speedMenuView = SelectMenuView<Float>(
        options: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        titleFormatter: { "\($0)x" }
    )
    
    // 控制面板容器 - 仅包含实际控制元素
    private let controlsContainer = UIView()
    private let topContainer = UIView()
    private let bottomContainer = UIView()
    
    // View Model
    private let viewModel = VideoControlsViewModel()
    private let disposeBag = DisposeBag()
    
    // Input Subjects
    private let isPlayingSubject = BehaviorSubject<Bool>(value: false)
    private let currentTimeSubject = BehaviorSubject<String>(value: "00:00")
    private let durationSubject = BehaviorSubject<String>(value: "00:00")
    private let progressSubject = BehaviorSubject<Float>(value: 0.0)
    private let currentSpeedSubject = BehaviorSubject<Float>(value: 1.0)
    private let isSeekingSubject = BehaviorSubject<Bool>(value: false)
    private let speedSelectedSubject = PublishSubject<Float>()
    
    // Output Properties
    var playPauseTapped: ControlEvent<Void> {
        return playPauseButton.rx.tap
    }
    
    var speedSelected: Observable<Float> {
        return speedSelectedSubject.asObservable()
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
        // 设置透明背景
        backgroundColor = .clear
        
        
        // 设置控制面板容器
        controlsContainer.backgroundColor = .clear
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(controlsContainer)
        
        // Configure speed button
        speedButton.setTitle("1.0x", for: .normal)
        speedButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure speed menu
        
        // Configure UI elements
        currentTimeLabel.style = .small
        currentTimeLabel.textAlignment = .center
        
        durationLabel.style = .small
        durationLabel.textAlignment = .center
        
        // Configure containers
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        controlsContainer.addSubview(topContainer)
        controlsContainer.addSubview(bottomContainer)
        addSubview(activityIndicator)
        addSubview(speedMenuView)
        
        // Add elements to containers
        topContainer.addSubview(currentTimeLabel)
        topContainer.addSubview(progressSlider)
        topContainer.addSubview(durationLabel)
        
        bottomContainer.addSubview(playPauseButton)
        bottomContainer.addSubview(speedButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 控制面板容器位于底部
            controlsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            controlsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            controlsContainer.heightAnchor.constraint(equalToConstant: 88), // 44 + 44
            
            // Container constraints 相对于 controlsContainer
            bottomContainer.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            bottomContainer.heightAnchor.constraint(equalToConstant: 44),
            
            topContainer.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 44),
            
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
            
            // Bottom container elements
            playPauseButton.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: NowUI.Sizing.buttonMedium),
            playPauseButton.heightAnchor.constraint(equalToConstant: NowUI.Sizing.buttonMedium),
            
            speedButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -NowUI.Spacing.large),
            speedButton.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
            speedButton.heightAnchor.constraint(equalToConstant: NowUI.Sizing.buttonMedium),
            
            // Activity indicator 位于整个视图中心
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
//            // Speed menu constraints - 相对于整个视图定位
//            speedMenuView.bottomAnchor.constraint(equalTo: speedButton.topAnchor, constant: -NowUI.Spacing.small),
//            speedMenuView.trailingAnchor.constraint(equalTo: speedButton.trailingAnchor),
            
            speedMenuView.bottomAnchor.constraint(equalTo: speedButton.topAnchor, constant: -NowUI.Spacing.small),
               speedMenuView.trailingAnchor.constraint(equalTo: speedButton.trailingAnchor),
               speedMenuView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    private func setupBindings() {
        // 已有的绑定代码保持不变
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
            isSeeking: isSeekingSubject.asObservable(),
            speedButtonTapped: speedButton.rx.tap.asObservable(),
            currentSpeed: currentSpeedSubject.asObservable()
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
        
        // 添加倍速相关的绑定
        output.speedButtonTitle
            .drive(speedButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        // 替换为:
        output.showSpeedMenu
            .map { !$0 }  // 反转布尔值
            .drive(onNext: { [weak self] isVisible in  // 更明确的参数名
                if isVisible {
                    self?.speedMenuView.showMenu()
                } else {
                    self?.speedMenuView.hideMenu()
                }
            })
            .disposed(by: disposeBag)

        // 绑定菜单选择事件
        speedMenuView.optionSelected
            .subscribe(onNext: { [weak self] speed in
                self?.speedSelectedSubject.onNext(speed)
            })
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
    
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        // 检查点击是否在speedMenuView或speedButton上
        let locationInMenu = speedMenuView.convert(location, from: self)
        let locationInButton = speedButton.convert(location, from: self)
        
        if !speedMenuView.bounds.contains(locationInMenu) &&
           !speedButton.bounds.contains(locationInButton) &&
           !speedMenuView.isHidden {
            speedMenuView.isHidden = true
        }
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
    
    // 在VideoControlsView.swift中添加
    func setupTapToDismissForSpeedMenu(in viewController: UIViewController) {
        viewController.setupTapToDismiss(for: speedMenuView, excluding: [speedButton])
    }
}
