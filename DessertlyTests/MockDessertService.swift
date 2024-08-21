//
//  MockDessertService.swift
//  Dessertly-RxSwiftTests
//
//  Created by Scott Gardner on 8/17/24.
//

import Foundation
import RxSwift
@testable import Dessertly_RxSwift

/// Mock implementation of `DessertServiceProtocol` for unit testing.
final class MockDessertService: DessertServiceProtocol {
    private let shouldThrow: Bool
    
    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }
    
    var desserts: Observable<[Dessert]> {
        if shouldThrow {
            return Observable.error(URLError(.badServerResponse))
        }
        
        return Observable.just([
            Dessert(id: "1", name: "Mock Dessert 1", thumbnail: ""),
            Dessert(id: "2", name: "Mock Dessert 2", thumbnail: "")
        ])
    }
    
    func dessertDetail(by id: String) -> Observable<DessertDetail> {
        if shouldThrow {
            return Observable.error(URLError(.badServerResponse))
        }
        
        return Observable.just(DessertDetail(
            id: id,
            name: "Mock Dessert",
            instructions: "Add sugar, then flour, and finally eggs. Mix well.",
            ingredients: ["Sugar": "1 cup", "Flour": "2 cups", "Eggs": "2 large"],
            imageUrl: ""
        ))
    }
}
