////
////  Mini.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/4/22.
////
//
//
//import UIKit
//import RxSwift
//import RxCocoa
//import RxRelay
//
//// ViewModel
//class Mini_ViewModel {
//    let outputText = PublishRelay<String>()
//    
//    init(inputText: Observable<String>) {
//        inputText
//            .map { "输入: \($0)" }
//            .bind(to: outputText)
//            .disposed(by: DisposeBag())
//    }
//}
//
//// ViewController
//class Mini_ViewController: UIViewController {
//    private let textField = UITextField(frame: .init(x: 20, y: 100, width: 200, height: 40))
//    private let label = UILabel(frame: .init(x: 20, y: 150, width: 200, height: 40))
//    private let disposeBag = DisposeBag()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        textField.borderStyle = .roundedRect
//        view.addSubview(textField)
//        view.addSubview(label)
//        
//        let viewModel = Mini_ViewModel(inputText: textField.rx.text.orEmpty.asObservable())
//        viewModel.outputText
//            .bind(to: label.rx.text)
//            .disposed(by: disposeBag)
//    }
//}
