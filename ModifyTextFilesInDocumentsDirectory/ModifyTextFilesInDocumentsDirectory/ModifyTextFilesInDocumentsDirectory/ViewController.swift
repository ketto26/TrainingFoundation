//
//  ViewController.swift
//  ModifyTextFilesInDocumentsDirectory
//
//  Created by Keto Nioradze on 28.07.25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    var inputTextField: UITextField!
    var outputTextView: UITextView!
    var saveButton: UIButton!
    var loadButton: UIButton!
    var statusLabel: UILabel!
    
    // MARK: - Constants
    let kSavedTextFilename = "user_saved_texts.txt"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        view.backgroundColor = .lightGray
        title = "File Operations"
    }
    
    // MARK: - UI Setup
    func setupUI() {
        inputTextField = UITextField()
        inputTextField.placeholder = "Enter text to save"
        inputTextField.borderStyle = .roundedRect
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.backgroundColor = .white
        inputTextField.textColor = .black
        view.addSubview(inputTextField)
        
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Text", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = .blue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        loadButton = UIButton(type: .system)
        loadButton.setTitle("Load All Texts", for: .normal)
        loadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loadButton.backgroundColor = .green
        loadButton.setTitleColor(.white, for: .normal)
        loadButton.layer.cornerRadius = 10
        loadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadButton)
        
        outputTextView = UITextView()
        outputTextView.isEditable = false
        outputTextView.layer.borderColor = UIColor.darkGray.cgColor
        outputTextView.layer.borderWidth = 1.0
        outputTextView.layer.cornerRadius = 8.0
        outputTextView.translatesAutoresizingMaskIntoConstraints = false
        outputTextView.backgroundColor = .white
        outputTextView.textColor = .black
        outputTextView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(outputTextView)
        
        statusLabel = UILabel()
        statusLabel.textAlignment = .center
        statusLabel.textColor = .gray
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            inputTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            inputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 15),
            loadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loadButton.heightAnchor.constraint(equalToConstant: 50),
            
            outputTextView.topAnchor.constraint(equalTo: loadButton.bottomAnchor, constant: 20),
            outputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            outputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            outputTextView.heightAnchor.constraint(equalToConstant: 200),
            
            statusLabel.topAnchor.constraint(equalTo: outputTextView.bottomAnchor, constant: 15),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    func setupActions() {
        saveButton.addTarget(self, action: #selector(saveText), for: .touchUpInside)
        loadButton.addTarget(self, action: #selector(loadAllTexts), for: .touchUpInside)
    }
    
    // MARK: - File Operations
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    @objc func saveText() {
        guard let textToSave = inputTextField.text, !textToSave.isEmpty else {
            updateStatus(message: "Please type something to save.", isError: true)
            return
        }
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(kSavedTextFilename)
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        let contentToAppend = "[\(timestamp)] \(textToSave)\n"
        
        do {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                try contentToAppend.write(to: fileURL, atomically: true, encoding: .utf8)
                updateStatus(message: "Created and saved to \(kSavedTextFilename)", isError: false)
                print("Successfully created and saved text to: \(fileURL.path)")
            } else {
                guard let fileHandle = FileHandle(forWritingAtPath: fileURL.path) else {
                    updateStatus(message: "Could not create FileHandle for writing.", isError: true)
                    return
                }
                
                defer {
                    fileHandle.closeFile()
                }
                
                fileHandle.seekToEndOfFile()
                
                if let dataToAppend = contentToAppend.data(using: .utf8) {
                    fileHandle.write(dataToAppend)
                    updateStatus(message: "Appended text to \(kSavedTextFilename)", isError: false)
                    print("Successfully appended text to: \(fileURL.path)")
                } else {
                    updateStatus(message: "Could not convert text to data.", isError: true)
                }
            }
            
            inputTextField.text = ""
        } catch {
            updateStatus(message: "Save failed: \(error.localizedDescription)", isError: true)
            print("Error saving text: \(error)")
        }
    }
    
    @objc func loadAllTexts() {
        let fileURL = getDocumentsDirectory().appendingPathComponent(kSavedTextFilename)
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let loadedText = try String(contentsOf: fileURL, encoding: .utf8)
                outputTextView.text = loadedText
                updateStatus(message: "Content from \(kSavedTextFilename) loaded!", isError: false)
                print("All texts loaded into output view from \(kSavedTextFilename).")
            } else {
                outputTextView.text = "No content to show."
                updateStatus(message: "No saved text file found.", isError: true)
                print("No saved text file found at \(fileURL.path)")
            }
        } catch {
            updateStatus(message: "Error loading file: \(error.localizedDescription)", isError: true)
            outputTextView.text = "Error loading content."
            print("Error reading file \(kSavedTextFilename): \(error)")
        }
    }
    
    // MARK: - Status Update
    func updateStatus(message: String, isError: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isError ? .red : .systemGreen
        statusLabel.alpha = 1.0
    }
}
