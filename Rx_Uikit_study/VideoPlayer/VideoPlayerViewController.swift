import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import MediaPlayer

class VideoPlayerViewController: UIViewController {
    
    // UI Components
    private let videoRenderView = VideoRenderView()
    private let controlsView = VideoControlsView()
    
    private lazy var volumeView: MPVolumeView = {
        let view = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 100, height: 100))
        view.showsVolumeSlider = true  // 改为 true
           view.alpha = 0.00001  // 让它透明但不影响功能
        return view
    }()
    
    // 指示器
    private let speedIndicatorLabel = IndicatorLabel()
    private let progressIndicatorLabel = IndicatorLabel()
    private let brightnessIndicatorLabel = IndicatorLabel()
    private let volumeIndicatorLabel = IndicatorLabel()
    
    
    // View Models
    private let playerViewModel: VideoPlayerViewModel
    
    // Rx
    private let disposeBag = DisposeBag()
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let viewWillDisappearSubject = PublishSubject<Void>()
    private let longPressBeganSubject = PublishSubject<Void>()
    private let longPressEndedSubject = PublishSubject<Void>()
    private let seekByOffsetSubject = PublishSubject<Double>()
    private let adjustBrightnessSubject = PublishSubject<Float>()
    private let adjustVolumeSubject = PublishSubject<Float>()
    
    // Gestures
    private var doubleTapGesture: UITapGestureRecognizer?
    private var longPressGesture: UILongPressGestureRecognizer?
    private var panGesture: UIPanGestureRecognizer?
    
    // Pan gesture state
    private enum GestureType {
        case seek
        case brightness
        case volume
        case none
    }
    private var panStartPoint: CGPoint?
    private var totalSeekOffset: Double = 0
    private var currentGestureType: GestureType = .none
    private var initialBrightness: CGFloat = 0
    private var initialVolume: Float = 0
    
    init(videoMetadata: VideoMetadata) {
        self.playerViewModel = VideoPlayerViewModel(videoMetadata: videoMetadata)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        bindViewModels()
        viewDidLoadSubject.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearSubject.onNext(())
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add video render view
        videoRenderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoRenderView)
        
        // Add controls view
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsView)
        
        // Add speed indicator label
        speedIndicatorLabel.text = "2.0x"
        view.addSubview(speedIndicatorLabel)
        
        // Add progress indicator label
        view.addSubview(progressIndicatorLabel)
        
        // Add brightness indicator label
        view.addSubview(brightnessIndicatorLabel)
        
        // Add volume indicator label
        view.addSubview(volumeIndicatorLabel)
        
        // Add volume view
        view.addSubview(volumeView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Video render view constraints
            videoRenderView.topAnchor.constraint(equalTo: view.topAnchor),
            videoRenderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoRenderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoRenderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Controls view constraints
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsView.heightAnchor.constraint(equalToConstant: 80),
            
            // Speed indicator label constraints
            speedIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speedIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Progress indicator label constraints
            progressIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Brightness indicator label constraints
            brightnessIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brightnessIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Volume indicator label constraints
            volumeIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeIndicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        // Add single tap gesture for showing/hiding controls
        let singleTapGesture = UITapGestureRecognizer()
        singleTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGesture)
        
        // Add double tap gesture for play/pause
        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        // Add long press gesture for speed control
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPressGesture)
        
        // Add pan gesture for seek control
        let panGesture = UIPanGestureRecognizer()
        view.addGestureRecognizer(panGesture)
        
        // Store gestures
        self.doubleTapGesture = doubleTapGesture
        self.longPressGesture = longPressGesture
        self.panGesture = panGesture
        
        // Require single tap to fail before recognizing double tap
        singleTapGesture.require(toFail: doubleTapGesture)
        
        // Bind single tap to show/hide controls
        singleTapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                UIView.animate(withDuration: 0.3) {
                    self?.controlsView.alpha = self?.controlsView.alpha == 0 ? 1 : 0
                }
            })
            .disposed(by: disposeBag)
        
        // Handle long press gesture
        longPressGesture.rx.event
            .subscribe(onNext: { [weak self] gesture in
                switch gesture.state {
                case .began:
                    self?.longPressBeganSubject.onNext(())
                    self?.speedIndicatorLabel.show()  // 使用show方法
                case .ended, .cancelled:
                    self?.longPressEndedSubject.onNext(())
                    self?.speedIndicatorLabel.hide()  // 使用hide方法
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // Handle pan gesture
        panGesture.rx.event
            .subscribe(onNext: { [weak self] gesture in
                self?.handlePanGesture(gesture)
            })
            .disposed(by: disposeBag)
    }
    
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let location = gesture.location(in: view)
        
        switch gesture.state {
        case .began:
            panStartPoint = gesture.location(in: view)
            totalSeekOffset = 0
            currentGestureType = .none  // 初始化为 none，稍后判断
            
            // 记录初始值
            initialBrightness = UIScreen.main.brightness
            let audioSession = AVAudioSession.sharedInstance()
            initialVolume = audioSession.outputVolume
            
        case .changed:
            // 如果还没有确定手势类型，现在判断
            if currentGestureType == .none {
                // 等到有足够的移动距离再判断方向
                if abs(translation.x) > 10 || abs(translation.y) > 10 {
                    let isLeftSide = location.x < view.bounds.width / 2
                    
                    if abs(translation.x) > abs(translation.y) {
                        currentGestureType = .seek
                    } else {
                        if isLeftSide {
                            currentGestureType = .brightness
                        } else {
                            currentGestureType = .volume
                        }
                    }
                }
            }
            
            // 根据手势类型处理
            switch currentGestureType {
            case .seek:
                let offset = Double(translation.x) / 100.0 * 5.0
                totalSeekOffset = offset
                
                let sign = offset >= 0 ? "+" : ""
                progressIndicatorLabel.text = "\(sign)\(Int(offset))s"
                progressIndicatorLabel.show(duration: 0.1)
                
            case .brightness:
                let deltaY = translation.y / view.bounds.height
                let newBrightness = max(0, min(1, initialBrightness - deltaY))
                UIScreen.main.brightness = newBrightness
                
                let brightnessPercentage = Int(newBrightness * 100)
                brightnessIndicatorLabel.text = "亮度: \(brightnessPercentage)%"
                brightnessIndicatorLabel.show(duration: 0.1)
                
            case .volume:
                let deltaY = translation.y / view.bounds.height
                let newVolume = max(0, min(1, initialVolume - Float(deltaY)))
                
                // 使用现有的 volumeView 来调节系统音量
                if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
                    DispatchQueue.main.async {
                        slider.value = newVolume
                    }
                }
                
                let volumePercentage = Int(newVolume * 100)
                volumeIndicatorLabel.text = "音量: \(volumePercentage)%"
                volumeIndicatorLabel.show(duration: 0.1)
                
            case .none:
                break
            }
            
        case .ended, .cancelled:
            switch currentGestureType {
            case .seek:
                if abs(totalSeekOffset) > 1.0 {
                    seekByOffsetSubject.onNext(totalSeekOffset)
                }
                progressIndicatorLabel.hide(duration: 0.3)
                
            case .brightness:
                brightnessIndicatorLabel.hide(duration: 0.3)
                
            case .volume:
                volumeIndicatorLabel.hide(duration: 0.3)
                
            case .none:
                break
            }
            
            // 重置状态
            panStartPoint = nil
            totalSeekOffset = 0
            currentGestureType = .none
            
        default:
            break
        }
    }
    
    private func bindViewModels() {
        // Create player input with double tap gesture
        let doubleTap = doubleTapGesture?.rx.event.map { _ in () } ?? Observable.never()
        
        let playerInput = VideoPlayerViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            playPauseTapped: Observable.merge(
                controlsView.playPauseTapped.asObservable(),
                doubleTap
            ),
//            seekTo: controlsView.sliderValueChanged.asObservable(),
            seekTo: controlsView.sliderSeekTo.asObservable(),
            viewWillDisappear: viewWillDisappearSubject.asObservable(),
            longPressBegan: longPressBeganSubject.asObservable(),
            longPressEnded: longPressEndedSubject.asObservable(),
            seekByOffset: seekByOffsetSubject.asObservable()
        )
        
        let playerOutput = playerViewModel.transform(input: playerInput)
        
        // 重要：绑定播放器到渲染视图
        playerOutput.player
            .drive(onNext: { [weak self] player in
                self?.videoRenderView.setPlayer(player)
            })
            .disposed(by: disposeBag)
        
        // Bind loading state
        playerOutput.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.controlsView.setLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        // Bind playing state
        playerOutput.isPlaying
            .drive(onNext: { [weak self] isPlaying in
                self?.controlsView.updatePlayingState(isPlaying)
            })
            .disposed(by: disposeBag)
        
        playerOutput.currentTime
            .withLatestFrom(playerOutput.duration) { currentTime, duration in
                return (currentTime, duration)
            }
            .drive(onNext: { [weak self] currentTime, duration in
                self?.controlsView.updateTime(current: currentTime, duration: duration)
            })
            .disposed(by: disposeBag)
        
        // Bind progress updates
        playerOutput.progress
            .drive(onNext: { [weak self] progress in
                print(" playerOutput.progress",progress)
                self?.controlsView.updateProgress(progress)
            })
            .disposed(by: disposeBag)
        
        // Handle errors
        playerOutput.error
            .drive(onNext: { [weak self] error in
                guard let error = error else { return }
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        playerOutput.seekCompleted
                   .drive(onNext: { [weak self] _ in
                       self?.controlsView.setSeekingCompleted()
                   })
                   .disposed(by: disposeBag)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 确保视图布局正确
        videoRenderView.setNeedsLayout()
    }
}
