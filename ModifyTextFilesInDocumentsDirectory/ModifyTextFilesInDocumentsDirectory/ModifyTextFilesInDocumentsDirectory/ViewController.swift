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
             inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
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

     let dateFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyyMMdd_HHmmss"
         return formatter
     }()

     @objc func saveText() {
         let textToSave = inputTextField.text
         if textToSave == nil || textToSave!.isEmpty {
             updateStatus(message: "Please type something to save.", isError: true)
             return
         }

         let filename = "my_saved_text_\(dateFormatter.string(from: Date())).txt"
         let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

         do {
             try textToSave!.write(to: fileURL, atomically: true, encoding: .utf8)
             updateStatus(message: "Saved: \(filename)", isError: false)
             inputTextField.text = ""
             print("Successfully saved text to: \(fileURL.path)")
         } catch {
             updateStatus(message: "Save failed: \(error.localizedDescription)", isError: true)
             print("Error saving text: \(error)")
         }
     }

     @objc func loadAllTexts() {
         var allTextsContent = ""
         let documentsURL = getDocumentsDirectory()

         do {
             let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

             var foundTextFiles: [URL] = []
             for fileURL in fileURLs {
                 if fileURL.pathExtension == "txt" && fileURL.lastPathComponent.hasPrefix("my_saved_text_") {
                     foundTextFiles.append(fileURL)
                 }
             }

             foundTextFiles.sort { $0.lastPathComponent < $1.lastPathComponent }

             if foundTextFiles.isEmpty {
                 updateStatus(message: "No text files found.", isError: true)
                 outputTextView.text = "No content to show."
                 return
             }

             for fileURL in foundTextFiles {
                 do {
                     let loadedText = try String(contentsOf: fileURL, encoding: .utf8)
                     let filename = fileURL.lastPathComponent
                     allTextsContent += "\(filename) \n"
                     allTextsContent += loadedText + "\n\n"
                 } catch {
                     print("Could not read file \(fileURL.lastPathComponent): \(error.localizedDescription)")
                     allTextsContent += "--- Error reading \(fileURL.lastPathComponent) ---\n"
                 }
             }
             outputTextView.text = allTextsContent
             updateStatus(message: "All texts loaded!", isError: false)
             print("All texts loaded into output view.")
         } catch {
             updateStatus(message: "Error loading files: \(error.localizedDescription)", isError: true)
             print("Error listing directory contents: \(error)")
         }
     }

     // MARK: - Status Update
     func updateStatus(message: String, isError: Bool) {
         statusLabel.text = message
         statusLabel.textColor = isError ? .red : .systemGreen
         statusLabel.alpha = 1.0
     }
 }
