//
//  ViewController.swift
//  NotificationSystem
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

extension Notification.Name {
    static let customNotification = Notification.Name("com.yourcompany.customNotification")
}

class SenderViewController: UIViewController {

    private let notifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Custom Notification", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false 
        button.addTarget(self, action: #selector(sendNotification), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Sender"
        setupUI()
    }

    private func setupUI() {
        view.addSubview(notifyButton)

        NSLayoutConstraint.activate([
            notifyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notifyButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func sendNotification() {
        print("Sending custom notification...")
        NotificationCenter.default.post(name: .customNotification, object: nil, userInfo: ["message": "Hello from Sender!"])
    }
}
