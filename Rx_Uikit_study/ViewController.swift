import UIKit

class ViewController: UIViewController {
    
    private let counterButton = UIButton()
    private let loginButton = UIButton()
    private let miniButton = UIButton()
    
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
        
        // 设置Mini按钮
        miniButton.setTitle("最小化示例", for: .normal)
        miniButton.setTitleColor(.white, for: .normal)
        miniButton.backgroundColor = .systemOrange
        miniButton.layer.cornerRadius = 8
        miniButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(miniButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            counterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            counterButton.widthAnchor.constraint(equalToConstant: 200),
            counterButton.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: counterButton.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            miniButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            miniButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            miniButton.widthAnchor.constraint(equalToConstant: 200),
            miniButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 添加按钮事件
        counterButton.addTarget(self, action: #selector(showCounterViewController), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(showLoginViewController), for: .touchUpInside)
        miniButton.addTarget(self, action: #selector(showMiniViewController), for: .touchUpInside)
    }
    
    @objc private func showCounterViewController() {
        let counterVC = CounterViewController()
        present(counterVC, animated: true, completion: nil)
    }
    
    @objc private func showLoginViewController() {
        let loginVC = LoginViewController()
        present(loginVC, animated: true, completion: nil)
    }
    
    @objc private func showMiniViewController() {
        let miniVC = Mini_ViewController()
        present(miniVC, animated: true, completion: nil)
    }
}
