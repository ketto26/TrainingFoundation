//
//  APIServiceTests.swift
//  UnitTesting
//

import XCTest
@testable import UnitTesting

final class APIServiceTests: XCTestCase {
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
    }
    
    override func tearDown() {
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: Fetch Users

    func test_apiService_fetchUsers_whenInvalidUrl_completesWithError() {
        let sut = makeSut()
        let expectation = self.expectation(description: "Fetch users with invalid URL should complete with error")
        
        sut.fetchUsers(urlString: "") { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .invalidUrl, "Expected invalidUrl error for invalid URL string")
                expectation.fulfill()
            } else {
                XCTFail("Expected failure but got success for invalid URL")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_apiService_fetchUsers_whenValidSuccessfulResponse_completesWithSuccess() {
        let response = """
        [
            { "id": 1, "name": "John Doe", "username": "johndoe", "email": "johndoe@gmail.com" },
            { "id": 2, "name": "Jane Doe", "username": "johndoe", "email": "johndoe@gmail.com" }
        ]
        """.data(using: .utf8)
        mockURLSession.mockData = response
        
        let sut = makeSut()
        let expectation = XCTestExpectation(description: "Fetch users with valid response should complete with success")
        
        sut.fetchUsers(urlString: "https://jsonplaceholder.typicode.com/users") { result in
            if case let .success(users) = result {
                XCTAssertEqual(users.count, 2, "Expected 2 users")
                XCTAssertEqual(users[0].name, "John Doe", "First user's name should be John Doe")
                XCTAssertEqual(users[1].id, 2, "Second user's ID should be 2")
                expectation.fulfill()
            } else {
                XCTFail("Expected success but got failure for valid response")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_apiService_fetchUsers_whenInvalidSuccessfulResponse_completesWithFailure() {
        let response = """
        [
            { "id": 1, "name": "John Doe", "username": "johndoe", "email": "johndoe@gmail.com" },
            { "id": "invalid_id", "name": "Jane Doe", "username": "janedoe", "email": "janedoe@gmail.com" }
        ]
        """.data(using: .utf8)
        mockURLSession.mockData = response
        
        let sut = makeSut()
        let expectation = XCTestExpectation(description: "Fetch users with invalid JSON should complete with parsing error")
        
        sut.fetchUsers(urlString: "https://jsonplaceholder.typicode.com/users") { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .parsingError, "Expected parsingError for invalid JSON response")
                expectation.fulfill()
            } else {
                XCTFail("Expected failure but got success for invalid JSON response")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_apiService_fetchUsers_whenError_completesWithFailure() {
        mockURLSession.mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        let sut = makeSut()
        let expectation = XCTestExpectation(description: "Fetch users with URLSession error should complete with unexpected error")
        
        sut.fetchUsers(urlString: "https://jsonplaceholder.typicode.com/users") { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .unexpected, "Expected unexpected error when URLSession returns an error")
                expectation.fulfill()
            } else {
                XCTFail("Expected failure but got success when URLSession returned an error")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: Fetch Users Async
    
    func test_apiService_fetchUsersAsync_whenInvalidUrl_completesWithError() async {
        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "")
        if case let .failure(error) = result {
            XCTAssertEqual(error, .invalidUrl, "Expected invalidUrl error for invalid URL string in async fetch")
        } else {
            XCTFail("Expected failure but got success for invalid URL in async fetch")
        }
    }
    
    func test_apiService_fetchUsersAsync_whenValidSuccessfulResponse_completesWithSuccess() async {
        let response = """
        [
            { "id": 1, "name": "Async User", "username": "asyncuser", "email": "async@email.com" }
        ]
        """.data(using: .utf8)
        mockURLSession.mockData = response
        
        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "https://jsonplaceholder.typicode.com/users")
        
        if case let .success(users) = result {
            XCTAssertEqual(users.count, 1, "Expected 1 user for async fetch")
            XCTAssertEqual(users[0].name, "Async User", "User name should match for async fetch")
        } else {
            XCTFail("Expected success but got failure for valid response in async fetch")
        }
    }
    
    
    func test_apiService_fetchUsersAsync_whenInvalidSuccessfulResponse_completesWithFailure() async {
        let response = """
        [
            { "id": 1, "name": "Async User", "username": "asyncuser", "email": "async@email.com" },
            { "id": "malformed", "name": "Another User" }
        ]
        """.data(using: .utf8)
        mockURLSession.mockData = response
        
        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "https://jsonplaceholder.typicode.com/users")
        
        if case let .failure(error) = result {
            XCTAssertEqual(error, .parsingError, "Expected parsingError for invalid JSON response in async fetch")
        } else {
            XCTFail("Expected failure but got success for invalid JSON response in async fetch")
        }
    }
    
    func test_apiService_fetchUsersAsync_whenError_completesWithFailure() async {
        mockURLSession.mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "https://jsonplaceholder.typicode.com/users")
        
        if case let .failure(error) = result {
            XCTAssertEqual(error, .unexpected, "Expected unexpected error when URLSession returns an error in async fetch")
        } else {
            XCTFail("Expected success but got failure when URLSession returned an error in async fetch")
        }
    }
    
    private func makeSut() -> APIService {
        APIService(urlSession: mockURLSession)
    }
}
