//
//  CalculatorTests.swift
//

import XCTest
@testable import UnitTesting

final class CalculatorTests: XCTestCase {
    var calculator: Calculator!
    
    override func setUp() {
        super.setUp()
        calculator = Calculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // Given two numbers, when multiplying, then the result is their product
    func test_multiplication() {
        let result = calculator.multiply(10, 20)
        XCTAssertEqual(200, result)
    }
    
    // Given a non-zero divisor, when dividing, then the result is the quotient
    func test_divideByNonZero() throws {
        let result1 = try calculator.divide(10.0, 2.0)
        XCTAssertEqual(5, result1, "10.0 divided by 2.0 should be 5")
        
        let result2 = try calculator.divide(-10.0, 2.0)
        XCTAssertEqual(-5, result2, "-10.0 divided by 2.0 should be -5")
        
        let result3 = try calculator.divide(10.0, -2.0)
        XCTAssertEqual(-5, result3, "10.0 divided by -2.0 should be -5")
        
        let result4 = try calculator.divide(10.0, 3.0)
        XCTAssertEqual(3, result4, "10.0 divided by 3.0 should be 3 (integer truncation)")
    }
    
    // Given a zero divisor, when dividing, then it throws a .divisionByZero error
    func test_divideByZero_throwsError() {
        XCTAssertThrowsError(try calculator.divide(10.0, 0.0)) { error in
            XCTAssertEqual(error as? Calculator.CalculatorError, Calculator.CalculatorError.divisionByZero, "Dividing by zero should throw .divisionByZero error")
        }
    }
    
    // Check 3 scenarios: < 10, 10, > 10
    func test_isGreaterThanTen() {
        XCTAssertFalse(calculator.isGreaterThanTen(5), "5 should not be greater than 10")
        
        XCTAssertFalse(calculator.isGreaterThanTen(10), "10 should not be greater than 10")
        
        XCTAssertTrue(calculator.isGreaterThanTen(15), "15 should be greater than 10")
    }
    
    func test_safeSquareRoot_whenPositiveNumber_returnsValue() {
        let result1 = calculator.safeSquareRoot(25.0)
        XCTAssertNotNil(result1, "Square root of 25.0 should not be nil")
        XCTAssertEqual(result1!, 5.0, accuracy: 0.0001, "Square root of 25.0 should be 5.0")
        
        let result2 = calculator.safeSquareRoot(0.0)
        XCTAssertNotNil(result2, "Square root of 0.0 should not be nil")
        XCTAssertEqual(result2!, 0.0, accuracy: 0.0001, "Square root of 0.0 should be 0.0")
        
        // Test with a non-perfect square
        let result3 = calculator.safeSquareRoot(2.0)
        XCTAssertNotNil(result3, "Square root of 2.0 should not be nil")
        XCTAssertEqual(result3!, 1.41421356, accuracy: 0.0001, "Square root of 2.0 should be approximately 1.4142")
    }
    
    func test_safeSquareRoot_whenNegativeNumber_returnsNil() {
        let result = calculator.safeSquareRoot(-4.0)
        XCTAssertNil(result, "Square root of a negative number should be nil")
    }
}
