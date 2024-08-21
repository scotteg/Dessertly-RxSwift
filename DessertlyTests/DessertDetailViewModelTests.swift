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

/// Tests for `DessertDetailViewModel` to ensure it correctly loads and manages dessert details.
final class DessertDetailViewModelTests: XCTestCase {
    private var viewModel: DessertDetailViewModel!
    private var mockService: MockDessertService!
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        mockService = MockDessertService()
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
