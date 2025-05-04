// IndicatorLabel.swift
import UIKit

class IndicatorLabel: UIView {
    
    // Private components
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.layer.cornerRadius = 12
        effectView.layer.masksToBounds = true
        effectView.alpha = 0
        return effectView
    }()
    
    private let label: TextLabel = {
        let label = TextLabel()
        label.textAlignment = .center
        label.font = NowUI.Typography.indicatorText
        return label
    }()
    
    // Public properties
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    var textColor: UIColor? {
        get { label.textColorOverride }
        set { label.textColorOverride = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add blur background
        addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add label to the blur view's content view
        blurEffectView.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure constraints
        NSLayoutConstraint.activate([
            // Blur effect view constraints
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Label constraints with padding
            label.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // Animation methods
    func show(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.blurEffectView.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }
    
    func hide(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.blurEffectView.alpha = 0
        }, completion: { _ in
            completion?()
        })
    }
    
    var isShowing: Bool {
        return blurEffectView.alpha > 0
    }
}
