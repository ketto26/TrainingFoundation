//
//  Task2View.swift
//  AsyncAwaitFinalTask
//
//  Created by Nikolay Dechko on 4/9/24.
//

import SwiftUI

struct Task2View: View {
    let task2API: Task2API = .init()

    @State var user: Task2API.User?
    @State var products: [Task2API.Product] = []
    @State var duration: TimeInterval?

    var body: some View {
        VStack {
            if let user, !products.isEmpty, let duration {
                Text("User name: \(user.name)").padding()
                List(products) { product in
                    Text("product description: \(product.description)")
                }
                Text("It took: \(duration) second(s)")
            } else {
                Text("Loading in progress")
            }
        }.task {
            do {
                let startDate = Date.now

                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        let fetchedUser = try await task2API.getUser()
                        await MainActor.run {
                            self.user = fetchedUser
                        }
                    }
                    group.addTask {
                        let fetchedProducts = try await task2API.getProducts()
                        await MainActor.run {
                            self.products = fetchedProducts
                        }
                    }
                    try await group.waitForAll()
                }

                let endDate = Date.now

                await MainActor.run {
                    self.duration = DateInterval(start: startDate, end: endDate).duration
                }
            } catch {
                print("Unexpected error: \(error.localizedDescription)")
            }
        }
    }
}

class Task2API: @unchecked Sendable {
    struct User: Decodable {
        let name: String
    }

    struct Product: Identifiable, Decodable {
        let id: String
        let description: String
    }

    func getUser() async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return .init(name: "John Smith")
    }

    func getProducts() async throws -> [Product] {
        try await Task.sleep(for: .seconds(1))
        return [
            .init(id: UUID().uuidString, description: "Some cool product"),
            .init(id: UUID().uuidString, description: "Some expensive product")
        ]
    }
}

#Preview {
    Task2View()
}
