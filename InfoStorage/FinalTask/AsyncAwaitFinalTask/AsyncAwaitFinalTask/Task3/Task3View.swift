import SwiftUI

struct Task3View: View {
    @State var currentStrength: Task3API.SignalStrenght = .unknown
    @State var running: Bool = false
    
    let api = Task3API()
    
    var body: some View {
        VStack {
            HStack {
                Text("Current signal strength: \(currentStrength.rawValue.capitalized)")
            }
            Button {
                if running {
                    running.toggle()
                    Task { await api.cancel() }
                } else {
                    running.toggle()
                    Task {
                        let stream = await api.signalStrength()
                        for await strength in stream {
                            currentStrength = strength
                        }
                        currentStrength = .unknown
                        print("stream finished")
                    }
                }
            } label: {
                if running {
                    Text("Cancel")
                } else {
                    Text("Start monitoring")
                }
            }
        }
    }
}

actor Task3API {
    enum SignalStrenght: String, CaseIterable {
        case weak, strong, excellent, unknown
    }

    private var signalMonitoringTask: Task<Void, Never>?

    func signalStrength() -> AsyncStream<SignalStrenght> {
        return AsyncStream { continuation in

            self.signalMonitoringTask = Task {
                continuation.onTermination = { @Sendable [weak self] _ in
                    guard let self = self else { return }
                    Task { await self.clearMonitoringTask() }
                    print("AsyncStream terminated.")
                }
                
                while !Task.isCancelled {
                    let randomStrength = SignalStrenght.allCases.filter { $0 != .unknown }.randomElement() ?? .unknown
                    continuation.yield(randomStrength)

                    do {
                        try await Task.sleep(for: .seconds(1))
                    } catch {
                        print("Error during sleep or task cancelled: \(error)")
                        break
                    }
                }
                continuation.finish()
                print("Signal monitoring task finished.")
            }
        }
    }
    
    private func clearMonitoringTask() {
        self.signalMonitoringTask = nil
    }
   
    func cancel() {
        signalMonitoringTask?.cancel()
    }
}

#Preview {
    Task3View()
}
