//
//  IndicatorManager.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


import UIKit

class IndicatorManager {
    enum IndicatorType {
        case speed
        case progress
        case brightness
        case volume
    }
    
    private let speedIndicator: IndicatorLabel
    private let progressIndicator: IndicatorLabel
    private let brightnessIndicator: IndicatorLabel
    private let volumeIndicator: IndicatorLabel
    
    init(speedIndicator: IndicatorLabel,
         progressIndicator: IndicatorLabel,
         brightnessIndicator: IndicatorLabel,
         volumeIndicator: IndicatorLabel) {
        self.speedIndicator = speedIndicator
        self.progressIndicator = progressIndicator
        self.brightnessIndicator = brightnessIndicator
        self.volumeIndicator = volumeIndicator
    }
    
    func showSpeedIndicator(speed: Float) {
        speedIndicator.text = String(format: "%.1fx", speed)
        speedIndicator.show(duration: PlayerConfiguration.UI.indicatorShowDuration)
    }
    
    func showProgressIndicator(offset: Double) {
        let sign = offset >= 0 ? "+" : ""
        progressIndicator.text = "\(sign)\(Int(offset))s"
        progressIndicator.show(duration: PlayerConfiguration.UI.indicatorShowDuration)
    }
    
    func showBrightnessIndicator(brightness: Float) {
        let percentage = Int(brightness * 100)
        brightnessIndicator.text = "亮度: \(percentage)%"
        brightnessIndicator.show(duration: PlayerConfiguration.UI.indicatorShowDuration)
    }
    
    func showVolumeIndicator(volume: Float) {
        let percentage = Int(volume * 100)
        volumeIndicator.text = "音量: \(percentage)%"
        volumeIndicator.show(duration: PlayerConfiguration.UI.indicatorShowDuration)
    }
    
    func hideIndicator(_ type: IndicatorType) {
        let indicator = getIndicator(for: type)
        indicator.hide(duration: PlayerConfiguration.UI.indicatorHideDuration)
    }
    
    private func getIndicator(for type: IndicatorType) -> IndicatorLabel {
        switch type {
        case .speed:
            return speedIndicator
        case .progress:
            return progressIndicator
        case .brightness:
            return brightnessIndicator
        case .volume:
            return volumeIndicator
        }
    }
}