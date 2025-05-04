//
//  BaseButton.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


import UIKit


// MARK: - Base Components

class BaseButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBase()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBase()
    }
    
    private func setupBase() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class TintableButton: BaseButton {
    var tintColorOverride: UIColor? {
        didSet {
            updateTintColor()
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
        updateTintColor()
    }
    
    private func updateTintColor() {
        tintColor = tintColorOverride ?? NowUI.Colors.controlTint
    }
}

class IconButton: TintableButton {
    func setIcon(_ imageName: String) {
        let image = UIImage(systemName: imageName)
        setImage(image, for: .normal)
    }
    
    func setIcon(_ image: UIImage?) {
        setImage(image, for: .normal)
    }
}

class TextButton: TintableButton {
    var textColorOverride: UIColor? {
        didSet {
            updateTextColor()
        }
    }
    
    var fontOverride: UIFont? {
        didSet {
            updateFont()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextAppearance()
    }
    
    private func setupTextAppearance() {
        updateTextColor()
        updateFont()
    }
    
    private func updateTextColor() {
        let color = textColorOverride ?? NowUI.Colors.textPrimary
        setTitleColor(color, for: .normal)
        setTitleColor(color.withAlphaComponent(0.6), for: .highlighted)
    }
    
    private func updateFont() {
        titleLabel?.font = fontOverride ?? NowUI.Typography.buttonText
    }
}