//
//  ViewController.swift
//  OperationQueueExample
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    private let customOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.example.CustomOperationQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        let mainQueueButton = UIButton(type: .system)
        mainQueueButton.setTitle("Run Operation on Main Queue", for: .normal)
        mainQueueButton.addTarget(self, action: #selector(runOperationOnMainQueue), for: .touchUpInside)
        mainQueueButton.translatesAutoresizingMaskIntoConstraints = false
        mainQueueButton.backgroundColor = .systemBlue
        mainQueueButton.setTitleColor(.white, for: .normal)
        mainQueueButton.layer.cornerRadius = 8
        mainQueueButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        view.addSubview(mainQueueButton)

        let customQueueButton = UIButton(type: .system)
        customQueueButton.setTitle("Run Operation on Custom Queue", for: .normal)
        customQueueButton.addTarget(self, action: #selector(runOperationOnCustomQueue), for: .touchUpInside)
        customQueueButton.translatesAutoresizingMaskIntoConstraints = false
        customQueueButton.backgroundColor = .systemGreen
        customQueueButton.setTitleColor(.white, for: .normal)
        customQueueButton.layer.cornerRadius = 8
        customQueueButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        view.addSubview(customQueueButton)

        NSLayoutConstraint.activate([
            mainQueueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainQueueButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            mainQueueButton.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),

            customQueueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customQueueButton.topAnchor.constraint(equalTo: mainQueueButton.bottomAnchor, constant: 20),
            customQueueButton.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])
    }

    // MARK: - Operation Creation
    private func createHeavyOperation() -> BlockOperation {
        let operation = BlockOperation {
            print("-")
            print("Operation \"A\" started")
            print("Current Thread (Inside Operation): \(Thread.current)")
            print("Is Main Thread (Inside Operation): \(Thread.current.isMainThread)")
            print("Thread Name (Inside Operation): \(Thread.current.name ?? "nil")")

            for _ in 0..<100_000_000 {
            }

            print("Operation \"A\" finished")
            print("-")
        }
        return operation
    }

    // MARK: - Button Actions
    @objc private func runOperationOnMainQueue() {
        print("Adding operation to OperationQueue.main ")
        let operation = createHeavyOperation()
        OperationQueue.main.addOperation(operation)
        print("Operation added to main queue.")
    }

    @objc private func runOperationOnCustomQueue() {
        print("\n Adding operation to customOperationQueue")
        let operation = createHeavyOperation()
        customOperationQueue.addOperation(operation)
        print("Operation added to custom queue.")
    }
}

