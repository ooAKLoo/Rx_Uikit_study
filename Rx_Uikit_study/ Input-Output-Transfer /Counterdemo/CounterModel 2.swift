//
//  CounterModel 2.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/4/22.
//


import UIKit
import RxSwift
import RxCocoa

// MARK: - 模型层
struct CounterModel {
    var count: Int
}

// MARK: - ViewModel层
class CounterViewModel {
    
    // MARK: - Input & Output 定义
    
    // Input: 接收来自ViewController的事件输入
    struct Input {
        let incrementTap: Observable<Void>
        let decrementTap: Observable<Void>
        let resetTap: Observable<Void>
    }
    
    // Output: 向ViewController提供需要的数据
    struct Output {
        let counterText: Driver<String>
        let canDecrement: Driver<Bool>
    }
    
    // MARK: - 私有属性
    private let disposeBag = DisposeBag()
    private let counter = BehaviorRelay<Int>(value: 0)
    
    // MARK: - Transfer 方法 (将Input转换为Output)
    func transform(input: Input) -> Output {
        // 处理增加计数的按钮点击
        input.incrementTap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = self.counter.value + 1
                self.counter.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        // 处理减少计数的按钮点击
        input.decrementTap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = self.counter.value - 1
                if newValue >= 0 {
                    self.counter.accept(newValue)
                }
            })
            .disposed(by: disposeBag)
        
        // 处理重置计数的按钮点击
        input.resetTap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.counter.accept(0)
            })
            .disposed(by: disposeBag)
        
        // 创建并返回Output
        return Output(
            // 将计数值转换为文本以显示
            counterText: counter
                .map { "当前计数: \($0)" }
                .asDriver(onErrorJustReturn: "错误"),
            
            // 计数值大于0时才能减少
            canDecrement: counter
                .map { $0 > 0 }
                .asDriver(onErrorJustReturn: false)
        )
    }
}

// MARK: - ViewController层
class CounterViewController: UIViewController {
    
    // MARK: - UI元素
    private let counterLabel = UILabel()
    private let incrementButton = UIButton()
    private let decrementButton = UIButton()
    private let resetButton = UIButton()
    private let closeButton = UIButton(type: .system)
    
    // MARK: - 私有属性
    private let viewModel = CounterViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - 生命周期方法
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - 设置UI
    private func setupUI() {
        view.backgroundColor = .white
        
        // 设置关闭按钮
        closeButton.setTitle("关闭", for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // 设置标签
        counterLabel.textAlignment = .center
        counterLabel.font = UIFont.systemFont(ofSize: 24)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(counterLabel)
        
        // 设置增加按钮
        incrementButton.setTitle("增加", for: .normal)
        incrementButton.setTitleColor(.white, for: .normal)
        incrementButton.backgroundColor = .systemBlue
        incrementButton.layer.cornerRadius = 8
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incrementButton)
        
        // 设置减少按钮
        decrementButton.setTitle("减少", for: .normal)
        decrementButton.setTitleColor(.white, for: .normal)
        decrementButton.backgroundColor = .systemRed
        decrementButton.layer.cornerRadius = 8
        decrementButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decrementButton)
        
        // 设置重置按钮
        resetButton.setTitle("重置", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = .systemGray
        resetButton.layer.cornerRadius = 8
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            
            incrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            incrementButton.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40),
            incrementButton.widthAnchor.constraint(equalToConstant: 120),
            incrementButton.heightAnchor.constraint(equalToConstant: 44),
            
            decrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            decrementButton.topAnchor.constraint(equalTo: incrementButton.bottomAnchor, constant: 20),
            decrementButton.widthAnchor.constraint(equalToConstant: 120),
            decrementButton.heightAnchor.constraint(equalToConstant: 44),
            
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: decrementButton.bottomAnchor, constant: 20),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 添加关闭按钮事件
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
    }
    
    // MARK: - 绑定ViewModel
    private func bindViewModel() {
        // 创建Input
        let input = CounterViewModel.Input(
            incrementTap: incrementButton.rx.tap.asObservable(),
            decrementTap: decrementButton.rx.tap.asObservable(),
            resetTap: resetButton.rx.tap.asObservable()
        )
        
        // 通过transform方法获取Output
        let output = viewModel.transform(input: input)
        
        // 绑定Output到UI
        output.counterText
            .drive(counterLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.canDecrement
            .drive(decrementButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 为禁用状态设置不同的外观
        output.canDecrement
            .drive(onNext: { [weak self] canDecrement in
                self?.decrementButton.alpha = canDecrement ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}