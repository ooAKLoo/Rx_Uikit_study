//
//  PlayerConfiguration.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


import Foundation

struct PlayerConfiguration {
    struct Gesture {
        static let longPressDuration: TimeInterval = 0.5
        static let minimumPanThreshold: CGFloat = 10
        static let speedAdjustmentRate: Float = 100.0
        static let initialSpeedMultiplier: Float = 1.5
        static let seekOffsetMultiplier: Double = 5.0
    }
    
    struct Speed {
        static let minimum: Float = 0.5
        static let maximum: Float = 6.0
        static let normal: Float = 1.0
    }
    
    struct UI {
        static let controlsAnimationDuration: TimeInterval = 0.3
        static let indicatorShowDuration: TimeInterval = 0.1
        static let indicatorHideDuration: TimeInterval = 0.3
        static let controlsHeight: CGFloat = 80
    }
    
    struct Video {
        static let seekTimescale: Int32 = 600
        static let timeObserverInterval: TimeInterval = 0.1
    }
}