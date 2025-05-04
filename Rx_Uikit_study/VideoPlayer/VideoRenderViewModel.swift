//
//  VideoRenderViewModel.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class VideoRenderViewModel {
    
    struct Input {
        let setPlayer: Observable<AVPlayer?>
        let viewDidLayoutSubviews: Observable<CGRect>
    }
    
    struct Output {
        let playerLayer: Driver<AVPlayerLayer?>
        let videoSize: Driver<CGSize>
    }
    
    func transform(input: Input) -> Output {
        let playerLayer = input.setPlayer
            .map { player -> AVPlayerLayer? in
                guard let player = player else { return nil }
                let layer = AVPlayerLayer(player: player)
                layer.videoGravity = .resizeAspect
                return layer
            }
            .asDriver(onErrorJustReturn: nil)
        
        let videoSize = input.setPlayer
            .compactMap { $0 }
            .flatMapLatest { player in
                player.rx.observe(CGSize.self, "currentItem.presentationSize")
                    .compactMap { $0 }
            }
            .asDriver(onErrorJustReturn: .zero)
        
        return Output(
            playerLayer: playerLayer,
            videoSize: videoSize
        )
    }
}
