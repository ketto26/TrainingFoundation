//
//  SwiftUIView.swift
//  AsyncAwaitFinalTask
//
//  Created by Nikolay Dechko on 4/9/24.
//

import SwiftUI

struct Task1View: View, @unchecked Sendable {
    let task1API = Task1API()
    @State var fact = "To get random number fact press the button below"

    var body: some View {
        VStack {
            Text(fact)
                .padding()

            Button(action: {
                Task {
                    do {
                        self.fact = try await task1API.getTrivia(for: .none) ?? "Loading Error: Fact not found"
                    } catch {
                        self.fact = "Loading Error: \(error.localizedDescription)"
                    }
                }
            }, label: {
                Text("Click me")
            })
        }
    }
}

// MARK: - Preview Provider
#Preview {
    Task1View()
}

// MARK: - Task1API
class Task1API: @unchecked Sendable {
    let baseURL = "http://numbersapi.com"
    let triviaPath = "random/trivia"
    private var session = URLSession.shared

    func getTrivia(for number: Int?) async throws -> String? {

        let urlString: String
        if let number = number {
            urlString = "\(baseURL)/\(number)/trivia"
        } else {
            urlString = "\(baseURL)/\(triviaPath)"
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        print("Fetching URL: \(url)")

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            let randomFact = String(data: data, encoding: .utf8)
            return randomFact
        } catch {
            throw error
        }
    }
}
