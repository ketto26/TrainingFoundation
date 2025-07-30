//
//  ListenerViewController.swift
//  NotificationSystem
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

class ListenerViewController: UIViewController {

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for notification..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("ListenerViewController deinitialized and observer removed.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Listener"
        setupUI()
        setupNotificationObserver()
    }

    private func setupUI() {
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleCustomNotification(_:)),
                                               name: .customNotification,
                                               object: nil)
        print("Observer added for customNotification.")
    }

    @objc private func handleCustomNotification(_ notification: Notification) {
        print("Custom notification received!")
        if let userInfo = notification.userInfo as? [String: String],
           let message = userInfo["message"] {
            statusLabel.text = "Notification received: \(message) at \(Date().formatted())"
        } else {
            statusLabel.text = "Notification received at \(Date().formatted())"
        }
    }
}
