//
//  ViewController.swift
//  RecentSearches
//
//  Created by Keto Nioradze on 29.07.25.
//

import UIKit

// MARK: - UserDefaults Extension for Key
extension UserDefaults {
    static let recentSearchesKey = "recentSearches"
}

// MARK: - SearchViewController
class SearchViewController: UIViewController {

    // MARK: - UI Elements
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter search term"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let recentSearchesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Data Source
    private var recentSearches: [String] = []

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recent Searches"
        view.backgroundColor = .systemBackground

        setupUI()
        loadRecentSearches()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(recentSearchesTableView)

        searchTextField.delegate = self
        recentSearchesTableView.dataSource = self
        recentSearchesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchCell")

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),

            recentSearchesTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            recentSearchesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recentSearchesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recentSearchesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Data Management
    private func saveSearchTerm(_ term: String) {
        var searches = UserDefaults.standard.stringArray(forKey: UserDefaults.recentSearchesKey) ?? []

        if let index = searches.firstIndex(of: term) {
            searches.remove(at: index)
        }

        searches.insert(term, at: 0)

        if searches.count > 5 {
            searches = Array(searches.prefix(5))
        }

        UserDefaults.standard.set(searches, forKey: UserDefaults.recentSearchesKey)

        loadRecentSearches()
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: UserDefaults.recentSearchesKey) ?? []
        recentSearchesTableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchTerm = textField.text, !searchTerm.isEmpty {
            saveSearchTerm(searchTerm)
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        cell.textLabel?.text = recentSearches[indexPath.row]
        return cell
    }
}
