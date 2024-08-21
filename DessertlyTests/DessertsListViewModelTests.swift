//
//  DessertsListViewModelTests.swift
//  Dessertly-RxSwiftTests
//
//  Created by Scott Gardner on 8/19/24.
//

import XCTest
import RxSwift
import RxBlocking
@testable import Dessertly_RxSwift

/// Tests for `DessertsListViewModel` to ensure it correctly loads and manages desserts.
final class DessertsListViewModelTests: XCTestCase {
    private var viewModel: DessertsListViewModel!
    private var mockService: MockDessertService!
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        mockService = MockDessertService()
        viewModel = DessertsListViewModel(dessertService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    /// Tests successful loading of desserts.
    func testLoadDessertsSuccess() throws {
        let desserts = try viewModel.desserts.toBlocking().first()
        
        XCTAssertEqual(desserts?.count, 2)
        XCTAssertEqual(desserts?[0].name, "Mock Dessert 1")
        XCTAssertEqual(desserts?[1].name, "Mock Dessert 2")
    }
    
    /// Tests loading desserts with a failure scenario.
    func testLoadDessertsFailure() {
        mockService = MockDessertService(shouldThrow: true)
        viewModel = DessertsListViewModel(dessertService: mockService)
        
        XCTAssertThrowsError(try viewModel.desserts.toBlocking().first())
    }
}
