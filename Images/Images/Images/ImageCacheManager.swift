//
//  ImageCacheManager.swift
//  Images
//
//  Created by Keto Nioradze on 28.07.25.
//

import Foundation
import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let cacheQueue = DispatchQueue(label: "image.cache.queue", attributes: .concurrent)
    
    private init() {
        let tempDir = fileManager.temporaryDirectory
        cacheDirectory = tempDir.appendingPathComponent("ImageCache")
        createCacheDirectoryIfNeeded()
    }
    
    private func createCacheDirectoryIfNeeded() {
        cacheQueue.async(flags: .barrier) {
            if !self.fileManager.fileExists(atPath: self.cacheDirectory.path) {
                do {
                    try self.fileManager.createDirectory(
                        at: self.cacheDirectory,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                } catch {
                    print("Failed to create cache directory: \(error)")
                }
            }
        }
    }
    
    func cacheImage(_ image: UIImage, for url: URL) {
        cacheQueue.async(flags: .barrier) {
            let cacheKey = self.cacheKey(for: url)
            let fileURL = self.cacheDirectory.appendingPathComponent(cacheKey)
            
            guard let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            do {
                try data.write(to: fileURL)
                print("Cached image for URL: \(url.lastPathComponent)")
            } catch {
                print("Failed to cache image: \(error)")
            }
        }
    }
    
    func cachedImage(for url: URL) -> UIImage? {
        let cacheKey = cacheKey(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        var image: UIImage?
        cacheQueue.sync {
            if fileManager.fileExists(atPath: fileURL.path) {
                image = UIImage(contentsOfFile: fileURL.path)
            }
        }
        return image
    }
    
    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            do {
                let contents = try self.fileManager.contentsOfDirectory(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: nil
                )
                
                for fileURL in contents {
                    try self.fileManager.removeItem(at: fileURL)
                }
                
                print("Cache cleared successfully")
            } catch {
                print("Failed to clear cache: \(error)")
            }
        }
    }
    
    func clearCacheIfNeeded() {
        let maxCacheSize: Int64 = 50 * 1024 * 1024 // 50 MB
        let currentSize = getCacheSize()
        
        if currentSize > maxCacheSize {
            print("Cache size \(currentSize) bytes exceeds limit. Clearing...")
            clearCache()
        }
    }
    
    func getCacheSize() -> Int64 {
        let contents = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        )
        
        return contents?.reduce(0) { total, url in
            let attributes = try? url.resourceValues(forKeys: [.fileSizeKey])
            return total + Int64(attributes?.fileSize ?? 0)
        } ?? 0
    }
    
    func getCacheStats() -> (size: Int64, count: Int) {
        let contents = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        )
        
        let size = getCacheSize()
        let count = contents?.count ?? 0
        
        return (size, count)
    }
    
    private func cacheKey(for url: URL) -> String {
        let hash = url.absoluteString.data(using: .utf8)!.sha256()
        return hash + ".jpg"
    }
}

// MARK: - String Extension for SHA256
private extension Data {
    func sha256() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
