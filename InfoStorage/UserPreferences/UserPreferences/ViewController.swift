//
//  ViewController.swift
//  UserPreferences
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

class ThemeManager {
    private static let userDefaultsThemeKey = "selectedAppTheme"

    enum ThemeMode: Int {
        case light = 0
        case dark = 1
        case system = 2

        var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return .unspecified
            }
        }
    }

    static func saveTheme(mode: ThemeMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: userDefaultsThemeKey)
    }

    static func loadTheme() -> ThemeMode {
        let rawValue = UserDefaults.standard.integer(forKey: userDefaultsThemeKey)
        return ThemeMode(rawValue: rawValue) ?? .system
    }

    static func applyTheme(mode: ThemeMode) {
        saveTheme(mode: mode)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = mode.userInterfaceStyle
            }
        }
    }
}

// MARK: - ViewController
class ViewController: UIViewController {

    private lazy var themeSegmentedControl: UISegmentedControl = {
        let items = ["Light", "Dark", "System"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = ThemeManager.loadTheme().rawValue
        control.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
        return control
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatusLabel()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if ThemeManager.loadTheme() == .system {
            updateStatusLabel()
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(themeSegmentedControl)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            themeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            themeSegmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            themeSegmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            themeSegmentedControl.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            themeSegmentedControl.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: themeSegmentedControl.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func themeChanged(_ sender: UISegmentedControl) {
        if let selectedTheme = ThemeManager.ThemeMode(rawValue: sender.selectedSegmentIndex) {
            ThemeManager.applyTheme(mode: selectedTheme)
            updateStatusLabel()
        }
    }

    private func updateStatusLabel() {
        let currentThemeMode = ThemeManager.loadTheme()
        let actualInterfaceStyle = traitCollection.userInterfaceStyle

        var statusText = "Selected Theme: \(currentThemeMode)"
        if currentThemeMode == .system {
            statusText += "\n(Currently: \(actualInterfaceStyle == .dark ? "Dark" : "Light") Mode based on System)"
        } else {
            statusText += "\n(App is set to \(currentThemeMode) Mode)"
        }
        statusLabel.text = statusText
    }
}
