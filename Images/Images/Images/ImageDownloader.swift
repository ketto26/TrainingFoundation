//
//  ImageDownloader.swift
//  Images
//
//  Created by Keto Nioradze on 28.07.25.
//

import Foundation
import UIKit

final class ImageDownloader {
    static let shared = ImageDownloader()
    
    private let session: URLSession
    private let cacheManager = ImageCacheManager.shared
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
    }
    
    func downloadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let cachedImage = cacheManager.cachedImage(for: url) {
            completion(.success(cachedImage))
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(.failure(ImageDownloadError.invalidData))
                }
                return
            }
            
            self.cacheManager.cacheImage(image, for: url)
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }
        
        task.resume()
    }
    
    func downloadImages(from urls: [URL], completion: @escaping ([Result<UIImage, Error>]) -> Void) {
        let group = DispatchGroup()
        var results = [Result<UIImage, Error>](repeating: .failure(ImageDownloadError.cancelled), count: urls.count)
        
        for (index, url) in urls.enumerated() {
            group.enter()
            downloadImage(from: url) { result in
                results[index] = result
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    func getRandomUnsplashImages(count: Int = 10, completion: @escaping ([URL]) -> Void) {
        let accessKey = "YOUR_ACCESS_KEY" //
        let urlString = "https://api.unsplash.com/photos/random?count=\(count)"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                completion([])
                return
            }
            
            let imageURLs = json.compactMap { item -> URL? in
                guard let urls = item["urls"] as? [String: Any],
                      let regularURL = urls["regular"] as? String else {
                    return nil
                }
                return URL(string: regularURL)
            }
            
            DispatchQueue.main.async {
                completion(imageURLs)
            }
        }
        
        task.resume()
    }
    
    func getPlaceholderImages(count: Int = 10) -> [URL] {
        // Fallback placeholder URLs for demo purposes
        let placeholders = [
            "https://picsum.photos/200/300?random=1",
            "https://picsum.photos/200/300?random=2",
            "https://picsum.photos/200/300?random=3",
            "https://picsum.photos/200/300?random=4",
            "https://picsum.photos/200/300?random=5",
            "https://picsum.photos/200/300?random=6",
            "https://picsum.photos/200/300?random=7",
            "https://picsum.photos/200/300?random=8",
            "https://picsum.photos/200/300?random=9",
            "https://picsum.photos/200/300?random=10"
        ]
        
        return placeholders.prefix(count).compactMap { URL(string: $0) }
    }
}

enum ImageDownloadError: Error {
    case invalidData
    case cancelled
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Invalid image data"
        case .cancelled:
            return "Download cancelled"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
