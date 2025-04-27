////
////  CounterModel 3.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/4/22.
////
//
//
//import UIKit
//
//// MARK: - 模型层
//struct CounterModel {
//    var count: Int
//}
//
//// MARK: - ViewModel层
//class CounterViewModel: NSObject {
//    
//    // MARK: - KVO观察键定义
//    static let counterKey = "counter"
//    
//    // MARK: - 可观察属性
//    @objc dynamic private(set) var counter: Int = 0
//    
//    // MARK: - 公开计算属性
//    @objc dynamic var counterText: String {
//        return "当前计数: \(counter)"
//    }
//    
//    @objc dynamic var canDecrement: Bool {
//        return counter > 0
//    }
//    
//    // MARK: - 公开方法
//    func increment() {
//        willChangeValue(for: \.counter)
//        counter += 1
//        didChangeValue(for: \.counter)
//    }
//    
//    func decrement() {
//        if counter > 0 {
//            willChangeValue(for: \.counter)
//            counter -= 1
//            didChangeValue(for: \.counter)
//        }
//    }
//    
//    func reset() {
//        willChangeValue(for: \.counter)
//        counter = 0
//        didChangeValue(for: \.counter)
//    }
//}
//
//// MARK: - ViewController层
//class CounterViewController: UIViewController {
//    
//    // MARK: - UI元素
//    private let counterLabel = UILabel()
//    private let incrementButton = UIButton()
//    private let decrementButton = UIButton()
//    private let resetButton = UIButton()
//    private let closeButton = UIButton(type: .system)
//    
//    // MARK: - 私有属性
//    private let viewModel = CounterViewModel()
//    private var observations = [NSKeyValueObservation]()
//    
//    // MARK: - 生命周期方法
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        bindViewModel()
//        updateUI()
//    }
//    
//    deinit {
//        // 清除所有观察
//        observations.forEach { $0.invalidate() }
//    }
//    
//    // MARK: - 设置UI
//    private func setupUI() {
//        view.backgroundColor = .white
//        
//        // 设置关闭按钮
//        closeButton.setTitle("关闭", for: .normal)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(closeButton)
//        
//        // 设置标签
//        counterLabel.textAlignment = .center
//        counterLabel.font = UIFont.systemFont(ofSize: 24)
//        counterLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(counterLabel)
//        
//        // 设置增加按钮
//        incrementButton.setTitle("增加", for: .normal)
//        incrementButton.setTitleColor(.white, for: .normal)
//        incrementButton.backgroundColor = .systemBlue
//        incrementButton.layer.cornerRadius = 8
//        incrementButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(incrementButton)
//        
//        // 设置减少按钮
//        decrementButton.setTitle("减少", for: .normal)
//        decrementButton.setTitleColor(.white, for: .normal)
//        decrementButton.backgroundColor = .systemRed
//        decrementButton.layer.cornerRadius = 8
//        decrementButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(decrementButton)
//        
//        // 设置重置按钮
//        resetButton.setTitle("重置", for: .normal)
//        resetButton.setTitleColor(.white, for: .normal)
//        resetButton.backgroundColor = .systemGray
//        resetButton.layer.cornerRadius = 8
//        resetButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(resetButton)
//        
//        // 设置约束
//        NSLayoutConstraint.activate([
//            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            
//            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            counterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
//            
//            incrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            incrementButton.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40),
//            incrementButton.widthAnchor.constraint(equalToConstant: 120),
//            incrementButton.heightAnchor.constraint(equalToConstant: 44),
//            
//            decrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            decrementButton.topAnchor.constraint(equalTo: incrementButton.bottomAnchor, constant: 20),
//            decrementButton.widthAnchor.constraint(equalToConstant: 120),
//            decrementButton.heightAnchor.constraint(equalToConstant: 44),
//            
//            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            resetButton.topAnchor.constraint(equalTo: decrementButton.bottomAnchor, constant: 20),
//            resetButton.widthAnchor.constraint(equalToConstant: 120),
//            resetButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//        
//        // 添加按钮事件
//        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
//        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
//        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
//        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
//    }
//    
//    // MARK: - 绑定ViewModel
//    private func bindViewModel() {
//        // 观察counterText属性
//        let textObservation = viewModel.observe(\.counterText, options: [.initial, .new]) { [weak self] (viewModel, change) in
//            guard let self = self, let newValue = change.newValue else { return }
//            self.counterLabel.text = newValue
//        }
//        observations.append(textObservation)
//        
//        // 观察canDecrement属性
//        let decrementObservation = viewModel.observe(\.canDecrement, options: [.initial, .new]) { [weak self] (viewModel, change) in
//            guard let self = self, let canDecrement = change.newValue else { return }
//            self.decrementButton.isEnabled = canDecrement
//            self.decrementButton.alpha = canDecrement ? 1.0 : 0.5
//        }
//        observations.append(decrementObservation)
//    }
//    
//    // MARK: - 更新UI
//    private func updateUI() {
//        // 初始UI设置 (KVO的initial选项会自动处理)
//    }
//    
//    // MARK: - 按钮事件处理
//    @objc private func incrementTapped() {
//        viewModel.increment()
//    }
//    
//    @objc private func decrementTapped() {
//        viewModel.decrement()
//    }
//    
//    @objc private func resetTapped() {
//        viewModel.reset()
//    }
//    
//    @objc private func dismissVC() {
//        dismiss(animated: true, completion: nil)
//    }
//}
