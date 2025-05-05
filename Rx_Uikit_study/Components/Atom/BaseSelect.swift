//
//  SelectOption.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/5.
//
//
//  SelectMenuView.swift
//  Rx_Uikit_study
//
//  Created on 2025/5/5.
//

import UIKit
import RxSwift
import RxCocoa

class SelectMenuView<T>: UIView {
    
    // MARK: - Properties
    private let stackView = UIStackView()
    private var optionButtons: [TextButton] = []
    private var options: [T] = []
    private var titleFormatter: (T) -> String
    
    // RxSwift
    private let selectedOptionSubject = PublishSubject<T>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Output
    var optionSelected: Observable<T> {
        return selectedOptionSubject.asObservable()
    }
    
    // MARK: - Initialization
    init(options: [T], titleFormatter: @escaping (T) -> String) {
        self.options = options
        self.titleFormatter = titleFormatter
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        self.titleFormatter = { _ in return "" }
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // 基础设置
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        
        // 样式设置
        backgroundColor = NowUI.Colors.background
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4
        
        // 设置堆栈视图
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // 约束
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        createOptionButtons()
    }
    
    private func createOptionButtons() {
        // 清除现有按钮
        optionButtons.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()
        
        // 为每个选项创建按钮
        for (index, option) in options.enumerated() {
            let button = TextButton()
            button.setTitle(titleFormatter(option), for: .normal)
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // 添加点击事件
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self, index < self.options.count else { return }
                    self.selectedOptionSubject.onNext(self.options[index])
                    self.isHidden = true
                })
                .disposed(by: disposeBag)
            
            optionButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        // 设置整体高度
        let totalHeight = CGFloat(options.count) * 40 // 每个按钮40高度
        heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
    }
    
    // MARK: - Public Methods
    func setOptions(_ newOptions: [T]) {
        self.options = newOptions
        createOptionButtons()
    }
    
    func toggleVisibility() {
        isHidden = !isHidden
    }
    
    func hideMenu() {
        isHidden = true
    }
    
    func showMenu() {
        isHidden = false
    }
}

// MARK: - Helper Extension for Tap Outside Detection
extension UIViewController {
    func setupTapToDismiss<T>(for menu: SelectMenuView<T>, excluding: [UIView]) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        // 存储菜单和排除视图到关联对象
        objc_setAssociatedObject(self, &AssociatedKeys.selectMenu, menu, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.excludingViews, excluding, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.view)
        
        guard let menu = objc_getAssociatedObject(self, &AssociatedKeys.selectMenu) as? UIView,
              let excludingViews = objc_getAssociatedObject(self, &AssociatedKeys.excludingViews) as? [UIView] else {
            return
        }
        
        // 检查点击是否在菜单或排除视图上
        let tapOnMenu = menu.point(inside: menu.convert(location, from: self.view), with: nil)
        let tapOnExcluded = excludingViews.contains(where: { view in
            view.point(inside: view.convert(location, from: self.view), with: nil)
        })
        
        if !tapOnMenu && !tapOnExcluded && !menu.isHidden {
            menu.isHidden = true
        }
    }
    
    private struct AssociatedKeys {
        static var selectMenu = "selectMenuKey"
        static var excludingViews = "excludingViewsKey"
    }
}
