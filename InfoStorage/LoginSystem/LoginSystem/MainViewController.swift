//
//  MainViewController.swift
//  LoginSystem
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - UI Elements
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        displayWelcomeMessage()
        
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        view.addSubview(welcomeLabel)
        view.addSubview(logoutButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 50),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func displayWelcomeMessage() {
        if let email = UserManager.shared.getLoggedInUserEmail() {
            welcomeLabel.text = "Welcome, \(email)!"
        } else {
            welcomeLabel.text = "Welcome!"
        }
    }

    // MARK: - Actions
    @objc func logoutButtonTapped() {
        UserManager.shared.clearLoginStatus()
        navigateToLoginScreen()
    }

    private func navigateToLoginScreen() {
        let loginVC = LoginViewController()
        
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = loginVC
            UIView.transition(with: sceneDelegate.window!,
                              duration: 0.5,
                              options: .transitionFlipFromLeft, 
                              animations: nil,
                              completion: nil)
        }
    }
}
