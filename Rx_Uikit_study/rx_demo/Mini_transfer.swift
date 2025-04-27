//
//  Mini 2.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/4/23.
//


//
//  ViewModel.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/4/22.
//

import UIKit
import RxSwift
import RxCocoa

// ViewModel
class Mini_TransferViewModel {
    // 输入
    struct Input {
        let text: Observable<String>
    }
    
    // 输出
    struct Output {
        let displayText: Driver<String>
    }
    
    // Transfer - 转换逻辑
    func transform(input: Input) -> Output {
        let displayText = input.text
            .map { "输入: \($0.uppercased())" }
            .asDriver(onErrorJustReturn: "")
        
        return Output(
            displayText: displayText
        )
    }
}

// ViewController
class Mini_TransferViewController: UIViewController {
    private let textField = UITextField(frame: .init(x: 20, y: 100, width: 200, height: 40))
    private let label = UILabel(frame: .init(x: 20, y: 150, width: 200, height: 40))
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        textField.borderStyle = .roundedRect
        view.addSubview(textField)
        view.addSubview(label)
        
        let viewModel = Mini_TransferViewModel()
        
        // 构建输入
        let input = Mini_TransferViewModel.Input(
            text: textField.rx.text.orEmpty.asObservable()
        )
        
        // 调用transform获取输出
        let output = viewModel.transform(input: input)
        
        // 绑定输出到UI
        output.displayText
            .drive(label.rx.text)
            .disposed(by: disposeBag)
    }
}
