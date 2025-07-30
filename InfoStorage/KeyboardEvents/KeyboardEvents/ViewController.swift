//
//  ViewController.swift
//  KeyboardEvents
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements

    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type something..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    var textFieldBottomConstraint: NSLayoutConstraint!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupDismissKeyboardGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: 250),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])

        textFieldBottomConstraint = textField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        textFieldBottomConstraint.isActive = true
    }

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Keyboard Observation
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.removeObserver(self,
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // MARK: - Keyboard Event Handlers

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let curveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0
        let animationCurve = UIView.AnimationCurve(rawValue: curveRawValue) ?? .easeInOut

        let animator = UIViewPropertyAnimator(duration: duration, curve: animationCurve)

        animator.addAnimations {
            self.textFieldBottomConstraint.constant = -keyboardFrame.height - 20
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let curveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0
        let animationCurve = UIView.AnimationCurve(rawValue: curveRawValue) ?? .easeInOut

        let animator = UIViewPropertyAnimator(duration: duration, curve: animationCurve)

        animator.addAnimations {
            self.textFieldBottomConstraint.constant = -50
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    // MARK: - Keyboard Dismissal

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Deinitialization

    deinit {
        print("ViewController deinitialized - Observers should have been removed.")
    }
}
