////
////  LoginViewModel.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/4/21.
////
//
//
//import UIKit
//import RxSwift
//import RxCocoa
//
//// ViewModel
//struct LoginViewModel {
//    struct Input {
//        let username: Observable<String>
//        let password: Observable<String>
//        let loginTap: Observable<Void>
//    }
//    
//    struct Output {
//        let loginSuccess: Observable<Bool>
//        let errorMessage: Observable<String>
//    }
//    
//    func transform(input: Input) -> Output {
//        let loginSuccess = input.loginTap
//            .withLatestFrom(Observable.combineLatest(input.username, input.password))
//            .map { username, password in
//                !username.isEmpty && !password.isEmpty
//            }
//        
//        let errorMessage = loginSuccess
//            .map { success in
//                success ? "" : "Username or password is empty"
//            }
//        
//        return Output(loginSuccess: loginSuccess, errorMessage: errorMessage)
//    }
//}
//
//// ViewController
//class LoginViewController: UIViewController {
//    let disposeBag = DisposeBag()
//    
//    // UI Elements
//    let usernameTextField = UITextField()
//    let passwordTextField = UITextField()
//    let loginButton = UIButton(type: .system)
//    
//    let viewModel = LoginViewModel()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        bindViewModel()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .white
//        
//        // Username TextField
//        usernameTextField.placeholder = "Username"
//        usernameTextField.borderStyle = .roundedRect
//        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(usernameTextField)
//        
//        // Password TextField
//        passwordTextField.placeholder = "Password"
//        passwordTextField.isSecureTextEntry = true
//        passwordTextField.borderStyle = .roundedRect
//        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(passwordTextField)
//        
//        // Login Button
//        loginButton.setTitle("Login", for: .normal)
//        loginButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(loginButton)
//        
//        // Constraints
//        NSLayoutConstraint.activate([
//            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
//            usernameTextField.widthAnchor.constraint(equalToConstant: 200),
//            
//            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
//            passwordTextField.widthAnchor.constraint(equalToConstant: 200),
//            
//            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20)
//        ])
//    }
//    
//    private func bindViewModel() {
//        // Input
//        let input = LoginViewModel.Input(
//            username: usernameTextField.rx.text.orEmpty.asObservable(),
//            password: passwordTextField.rx.text.orEmpty.asObservable(),
//            loginTap: loginButton.rx.tap.asObservable()
//        )
//        
//        // Transform
//        let output = viewModel.transform(input: input)
//        
//        // Output Binding
//        output.loginSuccess
//            .subscribe(onNext: { success in
//                if success {
//                    print("Login successful")
//                    // Navigate or show success UI
//                } else {
//                    print("Login failed")
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        output.errorMessage
//            .subscribe(onNext: { message in
//                if !message.isEmpty {
//                    print(message)
//                    // Show error (e.g., UIAlertController)
//                }
//            })
//            .disposed(by: disposeBag)
//    }
//}
