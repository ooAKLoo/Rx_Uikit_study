
//
//  DesignSystem.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//

import UIKit


// MARK: - Base Components
class TextLabel: UILabel {
    enum Style {
        case small
        case medium
        case large
        
        var font: UIFont {
            switch self {
            case .small: return NowUI.Typography.small
            case .medium: return NowUI.Typography.medium
            case .large: return NowUI.Typography.large
            }
        }
    }
    
    var style: Style = .medium {
        didSet {
            updateStyle()
        }
    }
    
    var textColorOverride: UIColor? {
        didSet {
            updateTextColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        updateStyle()
        updateTextColor()
    }
    
    private func updateStyle() {
        font = style.font
    }
    
    private func updateTextColor() {
        textColor = textColorOverride ?? NowUI.Colors.textPrimary
    }
}

class ActivityIndicator: UIActivityIndicatorView {
    var colorOverride: UIColor? {
        didSet {
            updateColor()
        }
    }
    
    override init(style: UIActivityIndicatorView.Style = .medium) {
        super.init(style: style)
        setupAppearance()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        hidesWhenStopped = true
        updateColor()
    }
    
    private func updateColor() {
        color = colorOverride ?? NowUI.Colors.controlTint
    }
}
