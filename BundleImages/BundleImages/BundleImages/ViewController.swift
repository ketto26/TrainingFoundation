//
//  ViewController.swift
//  BundleImages
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

struct AppConfiguration: Decodable {
    let appTitle: String
    let numberOfImagesToDisplay: Int
    let imageNames: [String]
    let featureEnabled: Bool
    let welcomeMessage: String
}

// MARK: - ViewController
class ViewController: UIViewController {
    
    // MARK: - UI Elements
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private var configuration: AppConfiguration?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loadConfiguration()
        
        setupUI()
        
        displayBundledImages()
    }
    
    // MARK: - Configuration Loading
    private func loadConfiguration() {
        guard let url = Bundle.main.url(forResource: "config", withExtension: "json") else {
            print("Error: config.json not found in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            configuration = try decoder.decode(AppConfiguration.self, from: data)
            print("Configuration loaded successfully: \(String(describing: configuration))")
        } catch {
            print("Error loading or parsing configuration: \(error)")
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        titleLabel.text = configuration?.appTitle ?? "Default App Title"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Image Display
    private func displayBundledImages() {
        guard let config = configuration else {
            print("Configuration not loaded, cannot display images.")
            return
        }
        
        let imagesToLoad = Array(config.imageNames.prefix(config.numberOfImagesToDisplay))
        
        for imageName in imagesToLoad {
            if let image = UIImage(named: imageName) {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 10
                imageView.layer.masksToBounds = true
                
                stackView.addArrangedSubview(imageView)
                
                imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
                imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
                print("Displayed image: \(imageName)")
            } else {
                print("Error: Image '\(imageName)' not found in bundle.")
            }
        }
        
        if config.featureEnabled {
            let featureLabel = UILabel()
            featureLabel.text = config.welcomeMessage
            featureLabel.font = UIFont.systemFont(ofSize: 18)
            featureLabel.textAlignment = .center
            featureLabel.numberOfLines = 0
            stackView.addArrangedSubview(featureLabel)
            print("Feature enabled message displayed: \(config.welcomeMessage)")
        }
    }
}
