//
//  ViewController.swift
//  OperationQueueTask3
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.example.DependencyCancellationQueue"
        queue.maxConcurrentOperationCount = 2
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

        let runWithDependencyButton = UIButton(type: .system)
        runWithDependencyButton.setTitle("Run With Dependency & Cancellation", for: .normal)
        runWithDependencyButton.addTarget(self, action: #selector(runOperationsWithDependencyAndCancellation), for: .touchUpInside)
        runWithDependencyButton.translatesAutoresizingMaskIntoConstraints = false
        runWithDependencyButton.backgroundColor = .systemPurple
        runWithDependencyButton.setTitleColor(.white, for: .normal)
        runWithDependencyButton.layer.cornerRadius = 8
        runWithDependencyButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        view.addSubview(runWithDependencyButton)

        let runWithoutDependencyButton = UIButton(type: .system)
        runWithoutDependencyButton.setTitle("Run Without Dependency", for: .normal)
        runWithoutDependencyButton.addTarget(self, action: #selector(runOperationsWithoutDependency), for: .touchUpInside)
        runWithoutDependencyButton.translatesAutoresizingMaskIntoConstraints = false
        runWithoutDependencyButton.backgroundColor = .systemOrange
        runWithoutDependencyButton.setTitleColor(.white, for: .normal)
        runWithoutDependencyButton.layer.cornerRadius = 8
        runWithoutDependencyButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        view.addSubview(runWithoutDependencyButton)

        NSLayoutConstraint.activate([
            runWithDependencyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            runWithDependencyButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            runWithDependencyButton.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),

            runWithoutDependencyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            runWithoutDependencyButton.topAnchor.constraint(equalTo: runWithDependencyButton.bottomAnchor, constant: 20),
            runWithoutDependencyButton.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])
    }

    // MARK: - Operation Creation Helper
    private func createHeavyOperation(name: String) -> BlockOperation {
        let operation = BlockOperation {
            guard !OperationQueue.current!.operations.first(where: { $0.name == name })!.isCancelled else {
                print("Operation \"\(name)\" was cancelled before starting.")
                return
            }

            print("-")
            print("Operation \"\(name)\" started")
            print("Current Thread (Inside \(name)): \(Thread.current)")
            print("Is Main Thread (Inside \(name)): \(Thread.current.isMainThread)")
            print("Thread Name (Inside \(name)): \(Thread.current.name ?? "nil")")

            for i in 0..<10_000_000 {
                if OperationQueue.current!.operations.first(where: { $0.name == name })!.isCancelled {
                    print("Operation \"\(name)\" cancelled during execution at iteration \(i).")
                    return
                }
            }

            print("Operation \"\(name)\" finished")
            print("-")
        }
        operation.name = name
        return operation
    }

    // MARK: - Operation Scenarios

    
    @objc private func runOperationsWithDependencyAndCancellation() {
        print("\n Running Operations with Dependency and Cancellation ")

        let operationB = createHeavyOperation(name: "B")
        let operationA = createHeavyOperation(name: "A")

        operationB.addDependency(operationA)

        operationA.addExecutionBlock { [weak operationB] in
            print("Operation \"A\" is executing its cancellation block...")
            operationB?.cancel()
            print("Operation \"B\" has been marked as cancelled by Operation \"A\".")
        }

        operationQueue.addOperation(operationA)
        operationQueue.addOperation(operationB)
        print("Operations A and B enqueued. B depends on A.")
    }

    @objc private func runOperationsWithoutDependency() {
        print("\n Running Operations Without Dependency ")

        let operationB = createHeavyOperation(name: "B")
        let operationA = createHeavyOperation(name: "A")

        operationQueue.addOperation(operationA)
        operationQueue.addOperation(operationB)
        print("Operations A and B enqueued without dependency.")
    }
}
