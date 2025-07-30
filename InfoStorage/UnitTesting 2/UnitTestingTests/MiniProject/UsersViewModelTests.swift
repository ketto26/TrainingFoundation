//
//  UsersViewModelTests.swift
//  UnitTesting
//

@testable import UnitTesting
import XCTest

class UsersViewModelTests: XCTestCase {
    var mockService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockService = MockAPIService()
    }
    
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }
    
    // assert that sut.fetchUsers(completion: {}) calls appropriate method of api service
    // use XCAssertEqual, fetchUsersCallsCount
    func test_viewModel_whenFetchUsers_callsApiService() {
        let sut = makeSut()
        
        // Initial state: no calls made
        XCTAssertEqual(mockService.fetchUsersCallsCount, 0, "fetchUsersCallsCount should be 0 initially")
        
        let expectation = XCTestExpectation(description: "Completion handler should be called")
        sut.fetchUsers {
            // After calling fetchUsers, the count should be 1
            XCTAssertEqual(self.mockService.fetchUsersCallsCount, 1, "fetchUsersCallsCount should be 1 after calling fetchUsers")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // assert that the passed url to api service is correct
    func test_viewModel_whenFetchUsers_passesCorrectUrlToApiService() {
        let sut = makeSut()
        let expectation = XCTestExpectation(description: "Fetch users completion")
        
        sut.fetchUsers {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockService.fetchUsersUrlString, "https://jsonplaceholder.typicode.com/users")
    }
    
    
    // assert that view model users are updated and error message is nil
    func test_viewModel_fetchUsers_whenSuccess_updatesUsers() {
        let expectedUsers = [User(id: 1, name: "name", username: "surname", email: "user@email.com")]
        mockService.fetchUsersResult = .success(expectedUsers)
        let sut = makeSut()
        
        XCTAssertTrue(sut.users.isEmpty, "Users should be empty initially")
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
        
        let expectation = XCTestExpectation(description: "Completion handler should be called")
        sut.fetchUsers {
            XCTAssertEqual(sut.users.count, expectedUsers.count, "Users count should match expected users count")
            XCTAssertEqual(sut.users.first?.id, expectedUsers.first?.id, "User ID should match")
            XCTAssertNil(sut.errorMessage, "Error message should be nil on success")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // assert that view model error message is "Unexpected error"
    func test_viewModel_fetchUsers_whenInvalidUrl_updatesErrorMessage() {
        // MockAPIService's default behavior for fetchUsersResult being nil is .failure(.unexpected)
        // To simulate invalidUrl, we need to explicitly set the mock result
        mockService.fetchUsersResult = .failure(.invalidUrl)
        let sut = makeSut()
        
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
        
        let expectation = XCTestExpectation(description: "Completion handler should be called")
        sut.fetchUsers {
            XCTAssertEqual(sut.errorMessage, "Unexpected error", "Error message should be 'Unexpected error' for invalidUrl")
            XCTAssertTrue(sut.users.isEmpty, "Users should remain empty on failure")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // assert that view model error message is "Unexpected error"
    func test_viewModel_fetchUsers_whenUnexectedFailure_updatesErrorMessage() {
        mockService.fetchUsersResult = .failure(.unexpected)
        let sut = makeSut()
        
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
        
        let expectation = XCTestExpectation(description: "Completion handler should be called")
        sut.fetchUsers {
            XCTAssertEqual(sut.errorMessage, "Unexpected error", "Error message should be 'Unexpected error' for unexpected failure")
            XCTAssertTrue(sut.users.isEmpty, "Users should remain empty on failure")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // assert that view model error message is "Error parsing JSON"
    func test_viewModel_fetchUsers_whenParsingFailure_updatesErrorMessage() {
        mockService.fetchUsersResult = .failure(.parsingError)
        let sut = makeSut()
        
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
        
        let expectation = XCTestExpectation(description: "Completion handler should be called")
        sut.fetchUsers {
            XCTAssertEqual(sut.errorMessage, "Error parsing JSON", "Error message should be 'Error parsing JSON' for parsing failure")
            XCTAssertTrue(sut.users.isEmpty, "Users should remain empty on failure")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // fetch users with successful result and after calling clear() assert users are empty
    func test_viewModel_clearUsers() {
        let initialUsers = [User(id: 1, name: "name", username: "surname", email: "user@email.com")]
        mockService.fetchUsersResult = .success(initialUsers)
        let sut = makeSut()
        
        let expectation = XCTestExpectation(description: "Fetch users completion should be called")
        sut.fetchUsers {
            XCTAssertFalse(sut.users.isEmpty, "Users should not be empty after successful fetch")
            
            sut.clearUsers()
            XCTAssertTrue(sut.users.isEmpty, "Users should be empty after calling clearUsers")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func makeSut() -> UsersViewModel {
        UsersViewModel(apiService: mockService)
    }
}
