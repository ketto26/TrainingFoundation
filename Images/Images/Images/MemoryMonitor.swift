//
//  MemoryMonitor.swift
//  Images
//
//  Created by Keto Nioradze on 28.07.25.
//

import UIKit

final class MemoryMonitor {
    static let shared = MemoryMonitor()
    
    private let cacheManager = ImageCacheManager.shared
    private var isMonitoring = false
    
    private init() {}
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        isMonitoring = true
        print("Memory monitoring started")
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        isMonitoring = false
        print("Memory monitoring stopped")
    }
    
    @objc private func handleMemoryWarning() {
        print("Memory warning received - clearing image cache")
        
        // Get current cache stats before clearing
        let stats = cacheManager.getCacheStats()
        print("Cache before clearing: \(stats.count) images, \(Double(stats.size) / 1024.0 / 1024.0) MB")
        
        // Clear the cache
        cacheManager.clearCache()
        
        // Force garbage collection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Trigger garbage collection
            autoreleasepool {
                // Temporary objects will be released here
            }
        }
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: .cacheClearedDueToMemoryPressure,
            object: nil
        )
    }
    
    func getSystemMemoryInfo() -> (used: UInt64, total: UInt64, pressure: Bool) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout.size(ofValue: integer_t(0)))
        
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                return task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), machPtr, &count)
            }
        }
        
        var usedMemory: UInt64 = 0
        if kerr == KERN_SUCCESS {
            usedMemory = UInt64(info.resident_size)
        }
        
        // Get total physical memory
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        
        // Check if we're under memory pressure (using 80% threshold)
        let pressure = Double(usedMemory) > Double(physicalMemory) * 0.8
        
        return (usedMemory, physicalMemory, pressure)
    }
    
    func logMemoryUsage() {
        let info = getSystemMemoryInfo()
        let usedMB = Double(info.used) / 1024.0 / 1024.0
        let totalMB = Double(info.total) / 1024.0 / 1024.0
        let percentage = (Double(info.used) / Double(info.total)) * 100
        
        print(String(format: "Memory Usage: %.1f MB / %.1f MB (%.1f%%)", usedMB, totalMB, percentage))
        
        if info.pressure {
            print("⚠️ Memory pressure detected")
        }
    }
}

extension Notification.Name {
    static let cacheClearedDueToMemoryPressure = Notification.Name("cacheClearedDueToMemoryPressure")
}
