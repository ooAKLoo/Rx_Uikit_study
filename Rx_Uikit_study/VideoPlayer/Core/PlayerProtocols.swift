//
//  VideoPlayable.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


import UIKit
import AVFoundation
import RxSwift
import RxCocoa

protocol VideoPlayable {
    func play()
    func pause()
    func seek(to time: Double)
    func setPlaybackSpeed(_ speed: Float)
}

protocol VideoControlDisplayable {
    func updatePlayingState(_ isPlaying: Bool)
    func updateTime(current: String, duration: String)
    func updateProgress(_ progress: Float)
    func setLoading(_ isLoading: Bool)
}

protocol IndicatorDisplayable {
    func showIndicator(_ type: IndicatorManager.IndicatorType, duration: TimeInterval)
    func hideIndicator(_ type: IndicatorManager.IndicatorType, duration: TimeInterval)
}

protocol GestureHandlerDelegate: AnyObject {
    func didUpdateSpeed(_ speed: Float)
    func didRequestSeek(offset: Double)
    func didUpdateBrightness(_ brightness: Float)
    func didUpdateVolume(_ volume: Float)
    func didTogglePlayPause()
    func didToggleControls()
    func didEndGestureAdjustment(_ gestureType: VideoGestureHandler.GestureType)  // 新增通用方法
    func didUpdateSeekOffset(_ offset: Double)  // 新增：实时更新seek偏移量
}
