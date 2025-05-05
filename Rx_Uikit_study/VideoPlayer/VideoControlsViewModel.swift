//
//  VideoControlsViewModel.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//

import Foundation
import RxSwift
import RxCocoa

class VideoControlsViewModel {
    
    struct Input {
        let isPlaying: Observable<Bool>
        let currentTime: Observable<String>
        let duration: Observable<String>
        let progress: Observable<Float>
        let playPauseTapped: Observable<Void>
        let sliderValueChanged: Observable<Float>
        let sliderTouchBegan: Observable<Void>
        let sliderTouchEnded: Observable<Void>
        let isSeeking: Observable<Bool>
        let speedButtonTapped: Observable<Void>  // 添加
                let currentSpeed: Observable<Float>      // 添加
    }
    
    struct Output {
        let playPauseButtonImage: Driver<UIImage?>
        let currentTimeText: Driver<String>
        let durationText: Driver<String>
        let progressValue: Driver<Float>
        let isSliderTracking: Driver<Bool>
        let speedButtonTitle: Driver<String>     // 添加
        let showSpeedMenu: Driver<Bool>          // 添加
    }
    
    private let playImage = UIImage(systemName: "play.fill")
    private let pauseImage = UIImage(systemName: "pause.fill")
    
    func transform(input: Input) -> Output {
        let playPauseButtonImage = input.isPlaying
            .distinctUntilChanged()
            .map { [weak self] isPlaying -> UIImage? in
                   guard let self = self else { return nil }
                   return isPlaying ? self.pauseImage : self.playImage
               }
            .asDriver(onErrorJustReturn: nil)
        
        let isSliderTracking = Observable.merge(
            input.sliderTouchBegan
                .map { true },
            input.sliderTouchEnded
                .map { false }
        )
        .startWith(false)
        .asDriver(onErrorJustReturn: false)
        
        let isUpdatingDisabled = Observable.combineLatest(
                    isSliderTracking.asObservable(),
                    input.isSeeking
                )
                .map { isTracking, isSeeking in
                    return isTracking || isSeeking
                }
                .asDriver(onErrorJustReturn: false)
        
        let progressValue = input.progress
                  .withLatestFrom(isUpdatingDisabled) { progress, disabled in
                      return (progress, disabled)
                  }
                  .filter { (progress, disabled) in !disabled }
                  .map { (progress, disabled) in progress }
                  .asDriver(onErrorJustReturn: 0)
        
        // 当前时间文本：拖动时不更新
            let currentTimeText = input.currentTime
                .withLatestFrom(isUpdatingDisabled) { time, disabled in
                    return (time, disabled)
                }
                .filter { (time, disabled) in !disabled }
                .map { (time, disabled) in time }
                .asDriver(onErrorJustReturn: "00:00")
        
        let speedButtonTitle = input.currentSpeed
                    .map { speed in "\(speed)x" }
                    .asDriver(onErrorJustReturn: "1.0x")
                
                let showSpeedMenu = input.speedButtonTapped
                    .scan(true) { current, _ in !current }
                    .asDriver(onErrorJustReturn: true)
        
        return Output(
            playPauseButtonImage: playPauseButtonImage,
            currentTimeText: currentTimeText,
            durationText: input.duration.asDriver(onErrorJustReturn: "00:00"),
            progressValue: progressValue,
            isSliderTracking: isSliderTracking,
            speedButtonTitle: speedButtonTitle,
            showSpeedMenu: showSpeedMenu
        )
    }
}
