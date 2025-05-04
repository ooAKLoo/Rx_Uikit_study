//
//  VideoRenderView.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation


class VideoRenderView: UIView {
    
    private let viewModel = VideoRenderViewModel()
    private let disposeBag = DisposeBag()
    
    // Input
    private let setPlayerSubject = PublishSubject<AVPlayer?>()
    private let layoutSubject = PublishSubject<CGRect>()
    
    // 保持对playerLayer的强引用
    private var playerLayer: AVPlayerLayer?
    
    // Output
    var videoSize: Driver<CGSize> {
        return output.videoSize
    }
    
    private var output: VideoRenderViewModel.Output!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBindings()
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        let input = VideoRenderViewModel.Input(
            setPlayer: setPlayerSubject.asObservable(),
            viewDidLayoutSubviews: layoutSubject.asObservable()
        )
        
        output = viewModel.transform(input: input)
        
        // 处理playerLayer
        output.playerLayer
            .drive(onNext: { [weak self] layer in
                guard let self = self else { return }
                
                // 移除旧的layer
                self.playerLayer?.removeFromSuperlayer()
                
                // 添加新的layer
                if let layer = layer {
                    layer.frame = self.bounds
                    layer.videoGravity = .resizeAspect
                    self.layer.addSublayer(layer)
                    self.playerLayer = layer
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setPlayer(_ player: AVPlayer?) {
        setPlayerSubject.onNext(player)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        layoutSubject.onNext(bounds)
    }
}
