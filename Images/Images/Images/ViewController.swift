//
//  ViewController.swift
//  Images
//
//  Created by Keto Nioradze on 28.07.25.
//

import UIKit

class ViewController: UIViewController {

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let size = (UIScreen.main.bounds.width - 6) / 3
        layout.itemSize = CGSize(width: size, height: size)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        return cv
    }()

    private let downloadButton = UIButton(type: .system)
    private let clearCacheButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let cacheSizeLabel = UILabel()

    private var imageUrls: [URL] = []
    
    private let downloader = ImageDownloader.shared
    private let cacheManager = ImageCacheManager.shared
    private let memoryMonitor = MemoryMonitor.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupNotifications()
        memoryMonitor.startMonitoring()
        updateCacheStats()
        
        fetchImageURLs()
    }

    deinit {
        memoryMonitor.stopMonitoring()
    }

    private func setupUI() {
        title = "Image Cache Demo"
        view.backgroundColor = .systemBackground

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.setTitle("Download New Images", for: .normal)
        downloadButton.backgroundColor = .systemBlue
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.layer.cornerRadius = 8
        view.addSubview(downloadButton)

        clearCacheButton.translatesAutoresizingMaskIntoConstraints = false
        clearCacheButton.setTitle("Clear Cache", for: .normal)
        clearCacheButton.backgroundColor = .systemRed
        clearCacheButton.setTitleColor(.white, for: .normal)
        clearCacheButton.layer.cornerRadius = 8
        view.addSubview(clearCacheButton)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        view.addSubview(statusLabel)

        cacheSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        cacheSizeLabel.textAlignment = .center
        cacheSizeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        cacheSizeLabel.textColor = .tertiaryLabel
        view.addSubview(cacheSizeLabel)

        NSLayoutConstraint.activate([
            downloadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            downloadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            downloadButton.widthAnchor.constraint(equalTo: clearCacheButton.widthAnchor),

            clearCacheButton.topAnchor.constraint(equalTo: downloadButton.topAnchor),
            clearCacheButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clearCacheButton.leadingAnchor.constraint(equalTo: downloadButton.trailingAnchor, constant: 20),

            statusLabel.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            cacheSizeLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 5),
            cacheSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cacheSizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: cacheSizeLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupActions() {
        downloadButton.addTarget(self, action: #selector(fetchImageURLs), for: .touchUpInside)
        clearCacheButton.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCacheCleared),
            name: .cacheClearedDueToMemoryPressure,
            object: nil
        )
    }
    
    @objc private func fetchImageURLs() {
        statusLabel.text = "Fetching image URLs..."
        downloadButton.isEnabled = false

        downloader.getRandomUnsplashImages(count: 30) { [weak self] urls in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.downloadButton.isEnabled = true
                if !urls.isEmpty {
                    self.imageUrls = urls
                    self.collectionView.reloadData()
                    self.statusLabel.text = "Ready to display \(urls.count) images"
                } else {
                    self.imageUrls = self.downloader.getPlaceholderImages(count: 30)
                    self.collectionView.reloadData()
                    self.statusLabel.text = "Fetched \(self.imageUrls.count) placeholder image URLs."
                }
                self.updateCacheStats()
                self.memoryMonitor.logMemoryUsage()
            }
        }
    }

    @objc private func clearCache() {
        cacheManager.clearCache()

        self.imageUrls.removeAll()
        
        collectionView.reloadData()
        statusLabel.text = "Cache cleared. Images removed from view."
        updateCacheStats()
    }

    @objc private func handleCacheCleared() {
        self.imageUrls.removeAll()
        collectionView.reloadData()
        statusLabel.text = "Cache cleared due to memory pressure. Images removed from view."
        updateCacheStats()
    }

    private func updateCacheStats() {
        let stats = cacheManager.getCacheStats()
        let sizeMB = Double(stats.size) / 1024.0 / 1024.0
        cacheSizeLabel.text = String(format: "Cache: %d images, %.2f MB", stats.count, sizeMB)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        let imageUrl = imageUrls[indexPath.item]

        downloader.downloadImage(from: imageUrl) { [weak cell] result in
            DispatchQueue.main.async {
                cell?.activityIndicator.stopAnimating()
                switch result {
                case .success(let image):
                    cell?.imageView.image = image
                case .failure(let error):
                    print("Error loading image for cell \(indexPath.item): \(error.localizedDescription)")
                    cell?.imageView.image = UIImage(systemName: "photo")
                }
            }
        }
        return cell
    
    }
}
