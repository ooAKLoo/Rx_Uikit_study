//
//  ViewController.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/4/21.
//

import UIKit

class ViewController: UIViewController {
    
    private let counterButton = UIButton()
    private let loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 设置标题标签
        let titleLabel = UILabel()
        titleLabel.text = "MVVM-Rx 示例"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // 设置Counter按钮
        counterButton.setTitle("计数器示例", for: .normal)
        counterButton.setTitleColor(.white, for: .normal)
        counterButton.backgroundColor = .systemBlue
        counterButton.layer.cornerRadius = 8
        counterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(counterButton)
        
        // 设置Login按钮
        loginButton.setTitle("登录示例", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .systemGreen
        loginButton.layer.cornerRadius = 8
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            counterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            counterButton.widthAnchor.constraint(equalToConstant: 200),
            counterButton.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: counterButton.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 添加按钮事件
        counterButton.addTarget(self, action: #selector(showCounterViewController), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(showLoginViewController), for: .touchUpInside)
    }
    
    @objc private func showCounterViewController() {
        let counterVC = CounterViewController()
        present(counterVC, animated: true, completion: nil)
    }
    
    @objc private func showLoginViewController() {
        let loginVC = LoginViewController()
        present(loginVC, animated: true, completion: nil)
    }
}

