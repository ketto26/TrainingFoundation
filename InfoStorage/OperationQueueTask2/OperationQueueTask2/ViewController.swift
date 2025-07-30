//
//  ViewController.swift
//  OperationQueueTask2
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements
    private let outputTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let runTestsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Run OperationQueue Tests", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(runAllTests), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(runTestsButton)
        view.addSubview(outputTextView)

        NSLayoutConstraint.activate([
            runTestsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            runTestsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            runTestsButton.heightAnchor.constraint(equalToConstant: 50),
            runTestsButton.widthAnchor.constraint(equalToConstant: 250),

            outputTextView.topAnchor.constraint(equalTo: runTestsButton.bottomAnchor, constant: 20),
            outputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            outputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            outputTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Test Runner
    @objc private func runAllTests() {
        outputTextView.text = ""
        appendOutput("--- Starting OperationQueue Tests ---")

        // MARK: Test Case 1: maxConcurrentOperationCount = 6
        appendOutput("\n--- Test Case 1: maxConcurrentOperationCount = 6 ---")
        runOperations(maxConcurrent: 6, dependencies: nil, lowPriorityOperation: nil)

        // MARK: Test Case 2: maxConcurrentOperationCount = 2
        appendOutput("\n--- Test Case 2: maxConcurrentOperationCount = 2 ---")
        runOperations(maxConcurrent: 2, dependencies: nil, lowPriorityOperation: nil)

        // MARK: Test Case 3: Dependencies (B depends on C, D depends on B)
        appendOutput("\n--- Test Case 3: Dependencies (B depends on C, D depends on B) ---")
        runOperations(maxConcurrent: 6, dependencies: [.b: .c, .d: .b], lowPriorityOperation: nil)

        // MARK: Test Case 4: Priority (A low priority)
        appendOutput("\n--- Test Case 4: Priority (A low priority) ---")
        runOperations(maxConcurrent: 6, dependencies: nil, lowPriorityOperation: .a)

        appendOutput("\n--- All Tests Finished ---")
    }

    // MARK: - Helper for appending output to TextView and Console
    private func appendOutput(_ text: String) {
        DispatchQueue.main.async {
            self.outputTextView.text += text + "\n"
            self.outputTextView.scrollRangeToVisible(NSMakeRange(self.outputTextView.text.count - 1, 1))
        }
        print(text)
    }

    // MARK: - Operation Definition
    enum OperationName: String {
        case a = "A"
        case b = "B"
        case c = "C"
        case d = "D"
        case e = "E"
    }

    private func createLongRunningOperation(name: OperationName) -> BlockOperation {
        let operation = BlockOperation { [weak self] in
            guard let self = self else { return }
            self.appendOutput("Operation \"\(name.rawValue)\" started")

            for _ in 0..<5_000_000 {
            }

            self.appendOutput("Operation \"\(name.rawValue)\" finished")
        }
        return operation
    }

    // MARK: - OperationQueue Runner
    private func runOperations(maxConcurrent: Int, dependencies: [OperationName: OperationName]?, lowPriorityOperation: OperationName?) {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = maxConcurrent

        var operations: [OperationName: BlockOperation] = [:]

        operations[.a] = createLongRunningOperation(name: .a)
        operations[.b] = createLongRunningOperation(name: .b)
        operations[.c] = createLongRunningOperation(name: .c)
        operations[.d] = createLongRunningOperation(name: .d)
        operations[.e] = createLongRunningOperation(name: .e)

        if let dependencies = dependencies {
            for (dependent, prerequisite) in dependencies {
                if let dependentOp = operations[dependent], let prerequisiteOp = operations[prerequisite] {
                    dependentOp.addDependency(prerequisiteOp)
                    appendOutput("Set dependency: \(dependent.rawValue) depends on \(prerequisite.rawValue)")
                }
            }
        }

        if let lowOpName = lowPriorityOperation, let lowOp = operations[lowOpName] {
            lowOp.queuePriority = .low
            appendOutput("Set priority of Operation \"\(lowOpName.rawValue)\" to low")
        }

        let orderedOperations: [BlockOperation] = [.a, .b, .c, .d, .e].compactMap { operations[$0] }
        operationQueue.addOperations(orderedOperations, waitUntilFinished: true) 
        appendOutput("--- Test Case Done ---")
    }
}
