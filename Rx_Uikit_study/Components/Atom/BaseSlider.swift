//
//  Slider111.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//

import UIKit


class Slider: UISlider {
    var minTrackColorOverride: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    var maxTrackColorOverride: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            let result = super.beginTracking(touch, with: event)
            if result {
                sendActions(for: .touchDown)
            }
            return result
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
        updateColors()
        
        // 创建自定义的小圆形滑块
        let thumbImage = createThumbImage(size: CGSize(width: 20, height: 20)) // 默认大小约为 31x31
        setThumbImage(thumbImage, for: .normal)
        setThumbImage(thumbImage, for: .highlighted)
    }
    
    private func updateColors() {
        minimumTrackTintColor = minTrackColorOverride ?? NowUI.Colors.progressTrack
        maximumTrackTintColor = maxTrackColorOverride ?? NowUI.Colors.progressTrackBackground
    }
    
    private func createThumbImage(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // 绘制圆形
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: rect)
            
            // 添加阴影
            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: 1),
                blur: 2,
                color: UIColor.black.withAlphaComponent(0.3).cgColor
            )
            
            // 添加边框
            context.cgContext.setStrokeColor(UIColor.black.withAlphaComponent(0.1).cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.strokeEllipse(in: rect.insetBy(dx: 0.25, dy: 0.25))
        }
    }
}
