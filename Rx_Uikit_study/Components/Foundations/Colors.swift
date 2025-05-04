//
//  Design.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//

import UIKit

// MARK: - Design System Namespace
enum NowUI {
    
    // MARK: - Colors
    enum Colors {
        // Base Colors
        static let primary = UIColor.white
        static let secondary = UIColor.red
        static let background = UIColor.black
        
        // Semantic Colors
        static let controlTint = primary
        static let progressTrack = secondary
        static let progressTrackBackground = primary.withAlphaComponent(0.5)
        static let overlayBackground = background.withAlphaComponent(0.5)
        static let textPrimary = primary
    }
    
    // MARK: - Typography
    enum Typography {
        static let small = UIFont.systemFont(ofSize: 12)
        static let medium = UIFont.systemFont(ofSize: 14)
        static let large = UIFont.systemFont(ofSize: 16)
        static let buttonText = UIFont.systemFont(ofSize: 14, weight: .medium)
        static let indicatorText = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    // MARK: - Sizing
    enum Sizing {
        static let iconSmall: CGFloat = 24
        static let iconMedium: CGFloat = 32
        static let iconLarge: CGFloat = 40
        
        static let buttonSmall: CGFloat = 32
        static let buttonMedium: CGFloat = 40
        static let buttonLarge: CGFloat = 48
        
        static let labelWidth: CGFloat = 50
    }
}
