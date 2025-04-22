////
////  CounterViewModel.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/4/22.
////
//
//import RxSwift
//import RxCocoa
//
//
//// MARK: - ViewModel层
//class CounterViewModel {
//    
//    // MARK: - Input & Output 定义
//    
//    // Input: 接收来自ViewController的事件输入
//    struct Input {
//        let incrementTap: Observable<Void>
//        let decrementTap: Observable<Void>
//        let resetTap: Observable<Void>
//    }
//    
//    // Output: 向ViewController提供需要的数据
//    struct Output {
//        let counterText: Driver<String>
//        let canDecrement: Driver<Bool>
//    }
//    
//    // MARK: - 私有属性
//    private let disposeBag = DisposeBag()
//    private let counter = BehaviorRelay<Int>(value: 0)
//    
//    // MARK: - Transfer 方法 (将Input转换为Output)
//    func transform(input: Input) -> Output {
//        // 处理增加计数的按钮点击
//        input.incrementTap
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else { return }
//                let newValue = self.counter.value + 1
//                self.counter.accept(newValue)
//            })
//            .disposed(by: disposeBag)
//        
//        // 处理减少计数的按钮点击
//        input.decrementTap
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else { return }
//                let newValue = self.counter.value - 1
//                if newValue >= 0 {
//                    self.counter.accept(newValue)
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        // 处理重置计数的按钮点击
//        input.resetTap
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else { return }
//                self.counter.accept(0)
//            })
//            .disposed(by: disposeBag)
//        
//        // 创建并返回Output
//        return Output(
//            // 将计数值转换为文本以显示
//            counterText: counter
//                .map { "当前计数: \($0)" }
//                .asDriver(onErrorJustReturn: "错误"),
//            
//            // 计数值大于0时才能减少
//            canDecrement: counter
//                .map { $0 > 0 }
//                .asDriver(onErrorJustReturn: false)
//        )
//    }
//}
