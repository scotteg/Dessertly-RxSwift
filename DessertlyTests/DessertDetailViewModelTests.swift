//
//  DessertDetailViewModelTests.swift
//  Dessertly-RxSwiftTests
//
//  Created by Scott Gardner on 8/19/24.
//

import XCTest
import RxSwift
import RxBlocking
@testable import Dessertly_RxSwift

import XCTest
import RxSwift
import RxBlocking

/// Tests for `DessertDetailViewModel` to ensure it correctly loads and manages dessert details.
final class DessertDetailViewModelTests: XCTestCase {
    private var viewModel: DessertDetailViewModel!
    private var mockService: MockDessertService!
    private var errorHandler: ErrorHandler!
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        mockService = MockDessertService()
        errorHandler = ErrorHandler.shared
        viewModel = DessertDetailViewModel(dessertID: "1", dessertService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    /// Tests successful loading of dessert details.
    func testLoadDessertDetailSuccess() throws {
        let detail = try viewModel.dessertDetail.toBlocking().first()
        
        XCTAssertNotNil(detail)
        XCTAssertEqual(detail?.name, "Mock Dessert")
    }
    
    /// Tests loading dessert details with a failure scenario.
    func testLoadDessertDetailFailure() {
        mockService = MockDessertService(shouldThrow: true)
        viewModel = DessertDetailViewModel(dessertID: "1", dessertService: mockService)
        
        XCTAssertThrowsError(try viewModel.dessertDetail.toBlocking().first())
    }
    
    /// Tests that an error is reported to the ErrorHandler on failure.
    func testErrorReportedToErrorHandler() {
        mockService = MockDessertService(shouldThrow: true)
        viewModel = DessertDetailViewModel(dessertID: "1", dessertService: mockService)
        
        let expectation = self.expectation(description: "Error should be reported")
        var reportedError: Error?
        
        // Subscribe to the error handler
        errorHandler.observeCurrentError()
            .compactMap { $0 } // Filter out nil errors.
            .take(1)
            .subscribe(onNext: { error in
                reportedError = error
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // Trigger the error by attempting to load dessert details.
        _ = try? viewModel.dessertDetail.toBlocking().first()
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertNotNil(reportedError)
        XCTAssertTrue(reportedError is URLError)
    }
    
    /// Tests sorting ingredients in ascending order.
    func testSortIngredientsAscending() throws {
        let detail = try viewModel.dessertDetail.toBlocking().first()
        
        let sortedIngredients = viewModel.sortIngredients(ingredients: detail?.ingredients ?? [:], ascending: true)
        XCTAssertEqual(sortedIngredients.map { $0.ingredient }, ["Eggs", "Flour", "Sugar"])
    }
    
    /// Tests sorting ingredients in descending order.
    func testSortIngredientsDescending() throws {
        let detail = try viewModel.dessertDetail.toBlocking().first()
        
        let sortedIngredients = viewModel.sortIngredients(ingredients: detail?.ingredients ?? [:], ascending: false)
        XCTAssertEqual(sortedIngredients.map { $0.ingredient }, ["Sugar", "Flour", "Eggs"])
    }
}
